/// Entity representing the redirect response for wallet topup.
class TopupRedirectEntity {
  final String type;
  final String actionUrl;
  final String method;
  final Map<String, String> params;

  const TopupRedirectEntity({
    required this.type,
    required this.actionUrl,
    required this.method,
    required this.params,
  });
}
