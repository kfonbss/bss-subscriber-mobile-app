import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

/// Result of payment from WebView

/// Simple Payment WebView page that loads a URL.
class PaymentWebViewPage extends StatefulWidget {
  final RechargeChangePlanRedirectEntity redirectEntity;

  const PaymentWebViewPage({super.key, required this.redirectEntity});

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  static const String _successUrlPattern = 'top-up-success';
  static const String _failureUrlPattern = 'top-up-failed';

  static const String _razorpayCheckoutType = 'RAZORPAY_CHECKOUT';
  static const String _paymentResultChannel = 'PaymentResult';

  late final WebViewControllerPlus _controller;
  bool _isLoading = true;
  bool _isInitialized = false;
  String? _initError;

  /// Razorpay reports its result through [_paymentResultChannel], so URL
  /// keyword matching (which could hit Razorpay's own pages) is skipped.
  bool get _isRazorpay => widget.redirectEntity.type == _razorpayCheckoutType;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _checkForPaymentResult(String url) {
    final result = _getPaymentResultFromUrl(url);
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  // 👇 print POST request
  void _printPostRequest(String actionUrl, Map<String, String> params) {
    debugPrint('═' * 60);
    debugPrint('📤 POST REQUEST');
    debugPrint('   URL: $actionUrl');
    debugPrint('   PARAMS:');
    for (final entry in params.entries) {
      debugPrint('     ${entry.key}: ${entry.value}');
    }

    // also print as curl
    final curlBuffer = StringBuffer();
    curlBuffer.write("curl -X POST '$actionUrl'");
    curlBuffer.write(
      " \\\n  -H 'Content-Type: application/x-www-form-urlencoded'",
    );
    for (final entry in params.entries) {
      curlBuffer.write(" \\\n  --data-urlencode '${entry.key}=${entry.value}'");
    }
    debugPrint('   CURL:');
    _printChunked(curlBuffer.toString());
    debugPrint('═' * 60);
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

  String? _resolveActionUrl() {
    final actionUrl = widget.redirectEntity.actionUrl;
    if (actionUrl != null && actionUrl.isNotEmpty) return actionUrl;

    if (widget.redirectEntity.type == 'PAYTM_CHECKOUT') {
      final params = widget.redirectEntity.params;
      final mid = params['mid'];
      final orderId = params['orderId'] ?? widget.redirectEntity.orderId;
      final isStaging = params['staging']?.toLowerCase() == 'true';
      final host =
          isStaging
              ? 'securestage.paytmpayments.com'
              : 'securegw.paytmpayments.com';
      if (mid != null &&
          mid.isNotEmpty &&
          orderId != null &&
          orderId.isNotEmpty) {
        return 'https://$host/theia/api/v1/showPaymentPage?mid=$mid&orderId=$orderId';
      }
    }
    return null;
  }

  Future<void> _initializeWebView() async {
    _controller = WebViewControllerPlus();

    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setBackgroundColor(Colors.white);

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          debugPrint('🌐 Page Started: $url'); // 👈 print request url
          if (mounted) setState(() => _isLoading = true);
          if (!_isRazorpay) _checkForPaymentResult(url);
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
          if (_isRazorpay) return NavigationDecision.navigate;
          final result = _getPaymentResultFromUrl(request.url);
          if (result != null) {
            Navigator.of(context).pop(result);
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
        onHttpError: (HttpResponseError error) {
          debugPrint('❌ HTTP Error:');
          debugPrint('   URL:    ${error.request?.uri}'); // 👈 uri not url
          debugPrint('   Status: ${error.response?.statusCode}');
        },
      ),
    );

    if (mounted) setState(() => _isInitialized = true);

    if (_isRazorpay) {
      await _loadRazorpayCheckout();
      return;
    }

    final actionUrl = _resolveActionUrl();
    final params = widget.redirectEntity.params;

    if (actionUrl == null || actionUrl.isEmpty) {
      // Previously this fell through with actionUrl == '' and produced
      // <form action=""> — which just posts back to the blank WebView with
      // no error, no crash, no hint that anything went wrong. Surface it
      // explicitly instead.
      debugPrint(
        '❌ No actionUrl available for redirect type '
        '"${widget.redirectEntity.type}" and no fallback could be built '
        'from params: $params',
      );
      _showInitError();
      return;
    }

    // 👇 print POST request details
    _printPostRequest(actionUrl, params);

    final inputFields = params.entries
        .map((entry) {
          final key = entry.key;
          final value = entry.value.replaceAll('"', '&quot;');
          return '<input type="hidden" name="$key" value="$value" />';
        })
        .join('\n');

    final html = '''
<form method="POST" action="$actionUrl">
  $inputFields
</form>
<script>
  document.forms[0].submit();
</script>
''';

    await _controller.loadHtmlString(html);
  }

  void _showInitError() {
    if (!mounted) return;
    setState(() {
      _initError = context.bssSubL10n.unableToStartPayment;
      _isLoading = false;
    });
  }

  /// Opens Razorpay's hosted Checkout (checkout.js) with the order created by
  /// the backend. The result comes back through [_paymentResultChannel]:
  /// `success` → paymentSuccess (the caller then checks the order status),
  /// closing after a failed attempt → paymentFailed, closing otherwise →
  /// paymentCancelled. Razorpay keeps the popup open after a failed attempt so
  /// the user can retry, so a failure is only reported once it's closed.
  Future<void> _loadRazorpayCheckout() async {
    final params = widget.redirectEntity.params;
    final keyId = params['razorpayKeyId'] ?? '';
    final orderId = params['razorpayOrderId'] ?? '';
    final amount = int.tryParse(params['amount'] ?? '');
    if (keyId.isEmpty || orderId.isEmpty || amount == null) {
      debugPrint('❌ Razorpay checkout missing params: $params');
      _showInitError();
      return;
    }

    await _controller.addJavaScriptChannel(
      _paymentResultChannel,
      onMessageReceived: (message) {
        debugPrint('💳 Razorpay result: ${message.message}');
        if (!mounted) return;
        final status = _razorpayStatus(message.message);
        if (status != null) Navigator.of(context).pop(status);
      },
    );

    final primary = AppColor.kPrimaryColor.toARGB32() & 0xFFFFFF;
    final options = <String, dynamic>{
      'key': keyId,
      'order_id': orderId,
      'amount': amount, // in paise, as sent by the backend
      'currency': params['currency'] ?? 'INR',
      'theme': {'color': '#${primary.toRadixString(16).padLeft(6, '0')}'},
    };

    final html = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script src="https://checkout.razorpay.com/v1/checkout.js"></script>
</head>
<body>
<script>
  function send(result) { $_paymentResultChannel.postMessage(JSON.stringify(result)); }
  var lastError = null;
  var options = ${jsonEncode(options)};
  options.handler = function (response) {
    send({ status: 'success', paymentId: response.razorpay_payment_id,
           orderId: response.razorpay_order_id, signature: response.razorpay_signature });
  };
  options.modal = {
    escape: false,
    confirm_close: true,
    ondismiss: function () {
      send(lastError ? { status: 'failed', error: lastError } : { status: 'cancelled' });
    }
  };
  if (typeof Razorpay === 'undefined') {
    send({ status: 'error', error: 'checkout.js failed to load' });
  } else {
    var rzp = new Razorpay(options);
    rzp.on('payment.failed', function (response) {
      lastError = response.error ? response.error.description : 'failed';
    });
    rzp.open();
  }
</script>
</body>
</html>
''';

    await _controller.loadHtmlString(html);
  }

  RechargeStatus? _razorpayStatus(String message) {
    try {
      final data = jsonDecode(message) as Map<String, dynamic>;
      switch (data['status']) {
        case 'success':
          return RechargeStatus.paymentSuccess;
        case 'failed':
          return RechargeStatus.paymentFailed;
        case 'cancelled':
          return RechargeStatus.paymentCancelled;
        case 'error':
          _showInitError();
          return null;
      }
    } catch (e) {
      debugPrint('❌ Could not parse Razorpay result: $e');
    }
    return null;
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

  RechargeStatus? _getPaymentResultFromUrl(String url) {
    if (url.startsWith('about:') || url.startsWith('data:')) return null;
    if (url.contains(_successUrlPattern)) return RechargeStatus.paymentSuccess;
    if (url.contains(_failureUrlPattern)) return RechargeStatus.paymentFailed;

    final path = url.toLowerCase();
    if (path.contains('success') || path.contains('complete'))
      return RechargeStatus.paymentSuccess;
    if (path.contains('fail') || path.contains('error'))
      return RechargeStatus.paymentFailed;
    if (path.contains('cancel')) return RechargeStatus.paymentCancelled;

    return null;
  }

  /// Escapes all HTML special characters so they are safe inside attribute values.
  String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;');

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
      Navigator.of(context).pop(RechargeStatus.paymentCancelled);
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
        body: Stack(
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
                child: CircularProgressIndicator(color: AppColor.kPrimaryColor),
              ),
          ],
        ),
      ),
    );
  }
}
