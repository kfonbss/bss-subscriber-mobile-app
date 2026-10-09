import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/features/notfication/domain/entity/notification_entity.dart';
import 'package:kfon_subscriber/features/notfication/domain/respository/notification_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

import '../../../../core/network/dio_client.dart';
import '../model/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl();

  @override
  Future<List<NotificationEntity>> getNotifications({
    int page = 0,
    int size = 20,
    String status = 'UNREAD',
  }) async {
    final response = await sl<DioClient>().get(
      ApiUrls.getNotificationsURL,
      queryParameters: {
        'grouped': false,
        'page': page,
        'size': size,
        'status': status,
      },
    );

    // APIResponse.data is already the JSON `data` field (the page object).
    final data = response.data;

    if (data is! Map) {
      return [];
    }

    final content = data['content'] as List? ?? [];

    return content
        .map(
          (item) => NotificationModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  @override
  Future<void> markAllAsRead() async {
    await sl<DioClient>().patch(ApiUrls.notificationReadAllURL);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await sl<DioClient>().get(
      ApiUrls.notificationUnreadCountURL,
    );

    // APIResponse.data is already the JSON `data` field, e.g. 9.
    final data = response.data;
    return data is num ? data.toInt() : 0;
  }
}
