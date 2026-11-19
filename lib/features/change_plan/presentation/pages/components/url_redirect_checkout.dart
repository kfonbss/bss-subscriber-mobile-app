import 'package:kfon_subscriber/features/change_plan/domain/entity/recharge_change_plan_redirect_entity.dart';

/// A gateway page opened straight from a URL (RailWire's Atom). The payment is
/// over once the gateway sends the browser back to the host in
/// [returnHostKey]; the backend's status check then decides the result.
class UrlRedirectCheckout {
  static const redirectType = 'URL_REDIRECT';
  static const returnHostKey = 'returnHost';

  static bool supports(RechargeChangePlanRedirectEntity redirect) =>
      redirect.type == redirectType &&
      (Uri.tryParse(redirect.actionUrl ?? '')?.hasScheme ?? false);

  /// Whether [url] is on the return host or one of its subdomains.
  static bool isReturn(String url, RechargeChangePlanRedirectEntity redirect) {
    final returnHost = redirect.params[returnHostKey]?.toLowerCase() ?? '';
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (returnHost.isEmpty || host.isEmpty) return false;
    return host == returnHost || host.endsWith('.$returnHost');
  }
}
