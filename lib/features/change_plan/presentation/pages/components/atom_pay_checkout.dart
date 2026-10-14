import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';

import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';
import 'package:kfon_subscriber/features/change_plan/presentation/bloc/discount_state.dart';

/// Atom (NTT DATA Payment Services) checkout, run in `PaymentWebViewPage`
/// with Atom's in-app WebView mode (`userAgent: 'mobile_webView'`):
///
/// 1. Load `atomcheckout.js` from the redirect's `cdnUrl`.
/// 2. `new AtomPaynetz({atomTokenId, merchId, custEmail, custMobile,
///    returnUrl, userAgent}, 'uat' | 'prod')` opens Atom's checkout in this
///    WebView; the bank pages also load here (no popup window).
/// 3. When the payment ends — or is cancelled / times out — Atom posts the
///    result to `returnUrl` (backend), which verifies it and redirects to
///    `…/recharge/order-summary?status=…`; [statusFromUrl] reads that.
/// 4. [resultChannel] only reports the checkout script failing to load (and
///    a cancel message, if Atom ever sends one instead of posting).
class AtomPayCheckout {
  AtomPayCheckout._();

  /// JavaScript channel the checkout page reports cancel / load errors on.
  static const String resultChannel = 'AtomResult';

  static const String _defaultCdnUrl =
      'https://pgtest.atomtech.in/staticdata/ots/js/atomcheckout.js';

  static bool supports(RechargeChangePlanRedirectEntity redirect) =>
      redirect.type.toUpperCase().contains('ATOM') ||
      (redirect.params['atomTokenId']?.isNotEmpty ?? false);

  /// The backend's `returnUrl`, made reachable from the phone.
  ///
  /// QA sends `https://rwbssqaapi.sritindia.com/bss-billing-finance-services/…`
  /// whose host doesn't resolve on the public internet, so Atom's result post
  /// fails. When the host can't be resolved, the same path is sent through
  /// the app's API base URL instead (`https://rwbssqa.sritindia.com/api/…`),
  /// which serves the same callback.
  static Future<String> reachableReturnUrl(
    RechargeChangePlanRedirectEntity redirect,
  ) async {
    final returnUrl = redirect.params['returnUrl'] ?? '';
    final uri = Uri.tryParse(returnUrl);
    if (uri == null || uri.host.isEmpty) return returnUrl;
    try {
      final found = await InternetAddress.lookup(uri.host);
      if (found.isNotEmpty) return returnUrl;
    } on SocketException {
      // Host not resolvable — fall through to the rewrite.
    }
    final base = ApiUrls.baseURL;
    if (base.isEmpty) return returnUrl;
    final rewritten =
        '${base.endsWith('/') ? base : '$base/'}'
        '${uri.path.replaceFirst(RegExp('^/'), '')}'
        '${uri.hasQuery ? '?${uri.query}' : ''}';
    debugPrint('⚠️ Atom returnUrl host unreachable, using $rewritten');
    return rewritten;
  }

  /// Checkout page HTML, or null when a required param is missing.
  /// [returnUrl] is the reachable return URL ([reachableReturnUrl]).
  static String? buildHtml(
    RechargeChangePlanRedirectEntity redirect, {
    required String returnUrl,
    String customerEmail = '',
    String customerMobile = '',
  }) {
    final p = redirect.params;
    final atomTokenId = p['atomTokenId'] ?? '';
    final merchantId = p['merchantId'] ?? p['merchId'] ?? '';
    if (atomTokenId.isEmpty || merchantId.isEmpty || returnUrl.isEmpty) {
      return null;
    }
    final cdnUrl =
        (p['cdnUrl']?.isNotEmpty ?? false) ? p['cdnUrl']! : _defaultCdnUrl;
    // Same rule as the web portal: test CDN → UAT environment.
    final lowerCdn = cdnUrl.toLowerCase();
    final env =
        lowerCdn.contains('pgtest') || lowerCdn.contains('paynetzuat')
            ? 'uat'
            : 'prod';
    final options = {
      'atomTokenId': atomTokenId,
      'merchId': merchantId,
      'custEmail': p['customerEmail'] ?? customerEmail,
      'custMobile': p['customerMobile'] ?? customerMobile,
      'returnUrl': returnUrl,
      // Atom's in-app WebView mode: no iframe / popup — checkout and the
      // bank pages load in this WebView, and the result (also cancel and
      // session timeout) is posted to returnUrl in the same window. Without
      // it Atom opens the bank page with window.open, which a WebView can't
      // host, and the payment stops at "Processing… Please Wait…".
      'userAgent': 'mobile_webView',
    };

    return '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
<script>
  function send(result) { $resultChannel.postMessage(result); }
  window.addEventListener('message', function (event) {
    if (event.data === 'cancelTransaction' || event.data === 'sessionTimeout') {
      send(event.data);
    }
  });
  var script = document.createElement('script');
  script.src = ${jsonEncode(cdnUrl)};
  script.onload = function () {
    if (!window.AtomPaynetz) { send('loadError'); return; }
    new AtomPaynetz(${jsonEncode(options)}, ${jsonEncode(env)});
  };
  script.onerror = function () { send('loadError'); };
  document.body.appendChild(script);
</script>
</body>
</html>
''';
  }

  /// Result for the page the backend redirects to after Atom posts to
  /// `returnUrl`, e.g.
  /// `/app/subscribers/portal/recharge/order-summary?status=success&orderId=…`.
  ///
  /// Only URLs on our own hosts (the return URL's or the API's) are matched,
  /// so Atom's pages never end the payment early. Pending counts as success:
  /// the caller then polls the order status, which settles it.
  static RechargeStatus? statusFromUrl(String url, Uri? returnUri) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    final ownHosts = {
      if (returnUri != null) returnUri.host,
      Uri.tryParse(ApiUrls.baseURL)?.host,
    };
    if (!ownHosts.contains(uri.host)) return null;
    // The return URL itself (Atom's form post) isn't a result page.
    if (returnUri != null && uri.path == returnUri.path) return null;

    switch (uri.queryParameters['status']?.toLowerCase()) {
      case 'success':
      case 'pending':
        return RechargeStatus.paymentSuccess;
      case 'failure':
      case 'failed':
        return RechargeStatus.paymentFailed;
      case 'cancel':
      case 'cancelled':
        return RechargeStatus.paymentCancelled;
    }
    final path = '${uri.path}?${uri.query}'.toLowerCase();
    if (path.contains('success') || path.contains('pending')) {
      return RechargeStatus.paymentSuccess;
    }
    if (path.contains('fail')) return RechargeStatus.paymentFailed;
    if (path.contains('cancel')) return RechargeStatus.paymentCancelled;
    return null;
  }
}
