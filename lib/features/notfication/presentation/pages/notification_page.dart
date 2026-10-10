import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/notfication/domain/entity/notification_entity.dart'
    show NotificationEntity;
import 'package:kfon_subscriber/features/notfication/domain/respository/notification_repository.dart';
import 'package:kfon_subscriber/features/notfication/presentation/bloc/notification_bloc.dart';
import 'package:kfon_subscriber/features/notfication/presentation/bloc/notification_event.dart';
import 'package:kfon_subscriber/features/notfication/presentation/bloc/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/shimmer/list_shimmers.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NotificationBloc(repository: sl<NotificationRepository>())
            ..add(const LoadNotifications()),
      child: const _NotificationView(),
    );
  }
}

class _NotificationView extends StatefulWidget {
  const _NotificationView();

  @override
  State<_NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<_NotificationView> {
  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      title: context.bssSubL10n.notifications,
      onBackPressed: () => Navigator.pop(context),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading || state is NotificationInitial) {
            return ListShimmer(
              itemCount: 6,
              itemHeight: 96,
              separatorHeight: 12,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
            );
          }

          if (state is NotificationEmpty) {
            return NoDataFound(
              errorMessage: context.bssSubL10n.youDontHaveAnyNotificationsYet,
            );
          }

          if (state is NotificationLoaded) {
            return _buildNotificationList(state.notifications);
          }

          if (state is NotificationError) {
            return RetryWidget(
              errorMessage: state.message,
              onRetry: () => context.read<NotificationBloc>().add(
                const LoadNotifications(),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationEntity> notifications) {
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
      itemCount: notifications.length,
      separatorBuilder: (_, __) {
        return SizedBox(height: 10.h);
      },
      itemBuilder: (context, index) {
        final notification = notifications[index];

        return _buildNotificationItem(notification);
      },
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColor.kNotificationBorder, width: 1.w),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNotificationIcon(),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                          color: AppColor.kNotificationDarkText,
                        ),
                      ),
                    ),
                    if (!notification.read)
                      Container(
                        margin: EdgeInsets.only(left: 8.w, top: 5.h),
                        height: 7.h,
                        width: 7.w,
                        decoration: BoxDecoration(
                          color: AppColor.kPrimaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  notification.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                    color: AppColor.kNotificationSubText,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildNotificationFooter(notification),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Container(
      height: 38.h,
      width: 38.w,
      decoration: BoxDecoration(
        color: AppColor.kIconBackground,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.language,
        size: 20.sp,
        color: AppColor.kPrimaryColor,
      ),
    );
  }

  Widget _buildNotificationFooter(NotificationEntity notification) {
    return Row(
      children: [
        if (notification.senderName != null &&
            notification.senderName!.isNotEmpty) ...[
          Icon(
            Icons.person_outline_rounded,
            size: 14.sp,
            color: AppColor.kMutedGrey,
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              notification.senderName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp, color: AppColor.kMutedGrey),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        if (notification.createdDate != null) ...[
          Icon(
            Icons.access_time_rounded,
            size: 13.sp,
            color: AppColor.kMutedGrey,
          ),
          SizedBox(width: 4.w),
          Text(
            _formatDate(notification.createdDate!),
            style: TextStyle(fontSize: 11.sp, color: AppColor.kMutedGrey),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
