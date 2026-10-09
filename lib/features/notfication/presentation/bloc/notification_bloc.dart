import 'package:kfon_subscriber/features/notfication/domain/respository/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;

  NotificationBloc({required this.repository})
    : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      emit(const NotificationLoading());

      final notifications = await repository.getNotifications(
        page: event.page,
        size: event.size,
        status: event.status,
      );

      if (notifications.isEmpty) {
        emit(const NotificationEmpty());
        return;
      }

      emit(NotificationLoaded(notifications: notifications));

      // Mark notifications as read after successfully
      // fetching and displaying the notification list.
      try {
        await repository.markAllAsRead();
      } catch (_) {
        // Don't change the loaded state if mark-all-read fails.
      }
    } catch (e) {
      emit(NotificationError(message: e.toString()));
    }
  }
}
