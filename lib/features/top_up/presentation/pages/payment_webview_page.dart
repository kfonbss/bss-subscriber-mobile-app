import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/top_up/domain/entity/topup_entity.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';

/// Result of payment from WebView
enum PaymentResult { success, failed, cancelled }

/// Simple Payment WebView page that loads a URL.
class PaymentWebViewPage extends StatefulWidget {
  /// The URL to load in the WebView
  final TopupRedirectEntity redirectEntity;

  /// Optional callback URL pattern to detect payment completion.
  final String? successUrlPattern;
  final String? failureUrlPattern;

  const PaymentWebViewPage({
    super.key,
    required this.redirectEntity,
    this.successUrlPattern,
    this.failureUrlPattern,
  });

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
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
          if (mounted) {
            setState(() => _isLoading = true);
          }
          _checkForPaymentResult(url);
        },
        onPageFinished: (String url) {
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        onNavigationRequest: (NavigationRequest request) {
          final result = _getPaymentResultFromUrl(request.url);
          if (result != null) {
            Navigator.of(context).pop(result);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    );

    if (mounted) {
      setState(() => _isInitialized = true);
    }

    final actionUrl = widget.redirectEntity.actionUrl;
    final params = widget.redirectEntity.params;

    // Build hidden input fields for form submission
    // Only escape double quotes to prevent breaking the value="" attribute
    final inputFields = params.entries
        .map((entry) {
          final key = entry.key;
          final value = entry.value.replaceAll('"', '&quot;');
          return '<input type="hidden" name="$key" value="$value" />';
        })
        .join('\n');

    // Create HTML with auto-submitting POST form (CCAvenue format)
    final html =
        '''
<form method="POST" action="$actionUrl">
  $inputFields
</form>

<script>
  document.forms[0].submit();
</script>
''';

    print("actionUrl: $actionUrl");
    print("params: $params");

    await _controller.loadHtmlString(html);
  }

  void _checkForPaymentResult(String url) {
    final result = _getPaymentResultFromUrl(url);
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  PaymentResult? _getPaymentResultFromUrl(String url) {
    if (url.startsWith('about:') || url.startsWith('data:')) return null;

    if (widget.successUrlPattern != null &&
        url.contains(widget.successUrlPattern!)) {
      return PaymentResult.success;
    }
    if (widget.failureUrlPattern != null &&
        url.contains(widget.failureUrlPattern!)) {
      return PaymentResult.failed;
    }

    final path = url.toLowerCase();
    if (path.contains('success') || path.contains('complete')) {
      return PaymentResult.success;
    }
    if (path.contains('fail') || path.contains('error')) {
      return PaymentResult.failed;
    }
    if (path.contains('cancel')) {
      return PaymentResult.cancelled;
    }

    return null;
  }

  Future<void> _onClose() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text('Are you sure you want to cancel this payment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes'),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) await _onClose();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColor.kPrimaryColor,
          foregroundColor: Colors.white,
          title: const Text(
            'Payment',
            style: TextStyle(
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
