import 'package:flutter/material.dart';
import 'package:webview_flutter_plus/webview_flutter_plus.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';

class CommonWebviewPage extends StatefulWidget {
  final String title;
  final String url;

  const CommonWebviewPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<CommonWebviewPage> createState() => _CommonWebviewPageState();
}

class _CommonWebviewPageState extends State<CommonWebviewPage> {
  late final WebViewControllerPlus _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewControllerPlus()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      scaffoldColor: Colors.white,
      appbarColor: Colors.white,
      onBackPressed: () => Navigator.pop(context),
      title: widget.title,
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: AppColor.kPrimaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
