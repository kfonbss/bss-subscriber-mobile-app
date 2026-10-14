import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/atom_pay_checkout.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/pages/components/razorpay_checkout.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

/// Completes a recharge payment and pops with a [PaymentOutcome].
///
/// Only two gateways are supported:
/// - Razorpay → native SDK ([RazorpayCheckout]).
/// - Atom → Atom's checkout script in a WebView ([AtomPayCheckout]); the
///   result is read from the page the backend redirects to.
class PaymentWebViewPage extends StatefulWidget {
  final RechargeChangePlanRedirectEntity redirectEntity;

  const PaymentWebViewPage({super.key, required this.redirectEntity});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewControllerPlus _controller;
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _initError;

  /// Set once a result is popped, so a late redirect can't pop twice.
  bool _finished = false;

  /// Atom return URL the result is posted to (after the reachability fix).
  Uri? _atomReturnUri;

  @override
  void initState() {
    super.initState();
    final redirect = widget.redirectEntity;
    if (RazorpayCheckout.supports(redirect)) {
      _runNativeCheckout(RazorpayCheckout.open(redirect));
    } else if (AtomPayCheckout.supports(redirect)) {
      _initializeAtomCheckout();
    } else {
      debugPrint('❌ Unsupported payment gateway: ${redirect.type}');
      WidgetsBinding.instance.addPostFrameCallback((_) => _showInitError());
    }
  }

  void _finish(RechargeStatus status) {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(PaymentOutcome(status));
  }

  /// SDK gateways open their own screen; this page only shows a loader
  /// behind it and returns the SDK's result.
  Future<void> _runNativeCheckout(Future<PaymentOutcome> checkout) async {
    final outcome = await checkout;
    if (mounted) Navigator.of(context).pop(outcome);
  }

  void _checkForPaymentResult(String url) {
    final result = AtomPayCheckout.statusFromUrl(url, _atomReturnUri);
    if (result != null) _finish(result);
  }

  // 👇 print page HTML content after load
  Future<void> _printPageContent() async {
    try {
      final title = await _controller.getTitle();
      final url = await _controller.currentUrl();

      debugPrint('═' * 60);
      debugPrint('📥 PAGE RESPONSE');
      debugPrint('   Title: $title');
      debugPrint('   URL:   $url');

      // get page HTML
      final html = await _controller.runJavaScriptReturningResult(
        'document.documentElement.outerHTML',
      );
      debugPrint('   HTML:');
      _printChunked(html.toString());
      debugPrint('═' * 60);
    } catch (e) {
      debugPrint('❌ Could not print page content: $e');
    }
  }

  // 👇 chunked print to avoid Flutter log truncation
  void _printChunked(String text) {
    const chunkSize = 800;
    for (int i = 0; i < text.length; i += chunkSize) {
      debugPrint(
        text.substring(
          i,
          i + chunkSize > text.length ? text.length : i + chunkSize,
        ),
      );
    }
  }

  Future<void> _initializeAtomCheckout() async {
    final redirect = widget.redirectEntity;
    final returnUrl = await AtomPayCheckout.reachableReturnUrl(redirect);
    _atomReturnUri = Uri.tryParse(returnUrl);
    final html = AtomPayCheckout.buildHtml(redirect, returnUrl: returnUrl);
    if (html == null) {
      debugPrint('❌ Atom checkout missing params: ${redirect.params}');
      _showInitError();
      return;
    }

    _controller = WebViewControllerPlus();
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setBackgroundColor(Colors.white);

    // Atom's checkout runs in an iframe from pgtest/payment.atomtech.in
    // inside our page. Android WebView blocks third-party (cross-site iframe)
    // cookies by default, so Atom loses its session and stops at
    // "Processing… You will be redirected to your bank's website".
    final platform = _controller.platform;
    final cookieManager = WebViewCookieManager().platform;
    if (platform is AndroidWebViewController &&
        cookieManager is AndroidWebViewCookieManager) {
      await cookieManager.setAcceptThirdPartyCookies(platform, true);
    }

    // Closing Atom's screen / a session timeout → cancelled; the script
    // failing to load → error screen.
    await _controller.addJavaScriptChannel(
      AtomPayCheckout.resultChannel,
      onMessageReceived: (message) {
        debugPrint('💳 Atom message: ${message.message}');
        if (message.message == 'loadError') {
          _showInitError();
        } else {
          _finish(RechargeStatus.paymentCancelled);
        }
      },
    );

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('🌐 Page Started: $url'); // 👈 print request url
          if (mounted) setState(() => _isLoading = true);
          _checkForPaymentResult(url);
        },
        onPageFinished: (String url) {
          debugPrint('✅ Page Finished: $url'); // 👈 print response url
          if (mounted) setState(() => _isLoading = false);
          _printPageContent(); // 👈 print page content
        },
        onNavigationRequest: (NavigationRequest request) {
          debugPrint(
            '🔀 Navigation Request: ${request.url}',
          ); // 👈 print navigation
          // UPI / app links (upi://, intent://, tez://, phonepe://…) can't
          // load in a WebView — hand them to the installed app.
          final uri = Uri.tryParse(request.url);
          if (uri != null &&
              uri.scheme.isNotEmpty &&
              !const {'http', 'https', 'about', 'data'}.contains(uri.scheme)) {
            _openExternalApp(request.url);
            return NavigationDecision.prevent;
          }
          final result = AtomPayCheckout.statusFromUrl(
            request.url,
            _atomReturnUri,
          );
          if (result != null) {
            _finish(result);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {
          // 👇 print errors
          debugPrint('❌ WebView Error:');
          debugPrint('   URL:         ${error.url}');
          debugPrint('   Code:        ${error.errorCode}');
          debugPrint('   Description: ${error.description}');
          debugPrint('   Type:        ${error.errorType}');
        },
        // A page with an invalid certificate (e.g. a bank's UAT site) is
        // cancelled silently by WebView and the payment just stalls — log
        // it. Never proceed past an SSL error on a payment page.
        onSslAuthError: (SslAuthError error) {
          final platform = error.platform;
          final url = platform is AndroidSslAuthError ? platform.url : '';
          debugPrint('❌ SSL Error: $url — ${platform.description}');
          error.cancel();
        },
        onHttpError: (HttpResponseError error) {
          debugPrint('❌ HTTP Error:');
          debugPrint('   URL:    ${error.request?.uri}'); // 👈 uri not url
          debugPrint('   Status: ${error.response?.statusCode}');
        },
      ),
    );

    if (mounted) setState(() => _isInitialized = true);

    // Serve the page from the backend's origin so Atom's iframe messages and
    // the final form post behave as they do on the web portal.
    final returnUri = _atomReturnUri;
    await _controller.loadHtmlString(
      html,
      baseUrl:
          returnUri == null ? null : '${returnUri.scheme}://${returnUri.host}',
    );
  }

  void _showInitError() {
    if (!mounted) return;
    setState(() {
      _initError = context.bssSubL10n.unableToStartPayment;
      _isLoading = false;
    });
  }

  /// Opens UPI / app deep links. Android `intent://…#Intent;scheme=upi;…;end`
  /// links are rewritten to the plain scheme URL (e.g. `upi://pay?...`).
  Future<void> _openExternalApp(String url) async {
    var target = url;
    if (url.startsWith('intent://')) {
      final scheme = RegExp(r';scheme=([^;]+);').firstMatch(url)?.group(1);
      final hashIndex = url.indexOf('#Intent');
      if (scheme != null && hashIndex > 0) {
        target = '$scheme://${url.substring('intent://'.length, hashIndex)}';
      }
    }
    final uri = Uri.tryParse(target);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) debugPrint('❌ No app found to open: $target');
  }

  Future<void> _onClose() async {
    final l10n = context.bssSubL10n;

    final shouldCancel = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(l10n.cancelPaymentTitle),
            content: Text(l10n.cancelPaymentMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.no),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.yes),
              ),
            ],
          ),
    );

    if (shouldCancel == true && mounted) {
      Navigator.of(
        context,
      ).pop(const PaymentOutcome(RechargeStatus.paymentCancelled));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _onClose();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.kPrimaryColor,
          foregroundColor: Colors.white,
          title: Text(
            l10n.payment,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'GeneralSans',
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: _onClose,
          ),
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              if (_isInitialized && _initError == null)
                WebViewWidget(controller: _controller),
              if (_initError != null)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 48.sp,
                          color: AppColor.kSuspendedStatusText,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          _initError!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'GeneralSans',
                            fontWeight: FontWeight.w500,
                            color: AppColor.kTextSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_isLoading || !_isInitialized)
                Center(
                  child: CircularProgressIndicator(
                    color: AppColor.kPrimaryColor,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
