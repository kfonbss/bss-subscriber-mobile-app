import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
/// Result of payment from WebView
enum PaymentResult { success, failed, cancelled }

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

  late final WebViewControllerPlus _controller;
  bool _isLoading = true;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    _controller = WebViewControllerPlus();

    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.setBackgroundColor(Colors.white);

    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (String url) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (String url) {
          if (mounted) setState(() => _isLoading = false);
        },
        onNavigationRequest: (NavigationRequest request) {
          final result = _getPaymentResultFromUrl(request.url);
          if (result != null) {
            Navigator.of(context).pop(result);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {},
      ),
    );

    if (!mounted) return;
    setState(() => _isInitialized = true);

    final actionUrl = widget.redirectEntity.actionUrl;
    final params = widget.redirectEntity.params;

    final inputFields = params.entries
        .map((entry) {
      final key = _escapeHtml(entry.key);
      final value = _escapeHtml(entry.value);
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

  PaymentResult? _getPaymentResultFromUrl(String url) {
    if (url.startsWith('about:') || url.startsWith('data:')) return null;
    if (url.contains(_successUrlPattern)) return PaymentResult.success;
    if (url.contains(_failureUrlPattern)) return PaymentResult.failed;

    final path = url.toLowerCase();
    if (path.contains('success') || path.contains('complete')) return PaymentResult.success;
    if (path.contains('fail') || path.contains('error')) return PaymentResult.failed;
    if (path.contains('cancel')) return PaymentResult.cancelled;

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
      builder: (context) => AlertDialog(
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
      Navigator.of(context).pop(PaymentResult.cancelled);
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
            style: const TextStyle(
              fontSize: 16,
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
            if (_isInitialized) WebViewWidget(controller: _controller),
            if (_isLoading || !_isInitialized)
              const Center(
                child: CircularProgressIndicator(color: AppColor.kPrimaryColor),
              ),
          ],
        ),
      ),
    );
  }
}