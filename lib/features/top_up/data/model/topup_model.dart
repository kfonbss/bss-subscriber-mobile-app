import 'package:kfon_subscriber/features/top_up/domain/entity/topup_entity.dart';

/// Model for parsing wallet topup redirect response from API.
class TopupRedirectModel {
  final String type;
  final String actionUrl;
  final String method;
  final Map<String, String> params;

  const TopupRedirectModel({
    required this.type,
    required this.actionUrl,
    required this.method,
    required this.params,
  });

  factory TopupRedirectModel.fromJson(Map<String, dynamic> json) {
    // Handle both response structures:
    // 1. { "data": { "redirect": { ... } } }
    // 2. { "redirect": { ... } }
    // 3. Direct redirect object: { "type": "...", "actionUrl": "...", ... }

    Map<String, dynamic> redirect;

    if (json.containsKey('data') && json['data'] is Map) {
      final data = json['data'] as Map<String, dynamic>;
      redirect = data['redirect'] as Map<String, dynamic>? ?? {};
    } else if (json.containsKey('redirect') && json['redirect'] is Map) {
      redirect = json['redirect'] as Map<String, dynamic>;
    } else if (json.containsKey('type') && json.containsKey('actionUrl')) {
      // Direct redirect object
      redirect = json;
    } else {
      redirect = {};
    }

    final paramsMap = redirect['params'] as Map<String, dynamic>? ?? {};

    return TopupRedirectModel(
      type: redirect['type']?.toString() ?? '',
      actionUrl: redirect['actionUrl']?.toString() ?? '',
      method: redirect['method']?.toString() ?? '',
      params: paramsMap.map(
        (key, value) => MapEntry(key, value?.toString() ?? ''),
      ),
    );
  }

  TopupRedirectEntity toEntity() {
    return TopupRedirectEntity(
      type: type,
      actionUrl: actionUrl,
      method: method,
      params: params,
    );
  }
}
