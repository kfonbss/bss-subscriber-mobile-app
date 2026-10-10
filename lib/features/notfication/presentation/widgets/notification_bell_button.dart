import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/notfication/domain/respository/notification_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Bell icon that opens the notification page and shows the unread count
/// as a badge. The count is fetched on build and again after returning
/// from the notification page (which marks everything as read).
class NotificationBellButton extends StatefulWidget {
  final String iconAsset;
  final double iconSize;

  const NotificationBellButton({
    super.key,
    required this.iconAsset,
    required this.iconSize,
  });

  @override
  State<NotificationBellButton> createState() => _NotificationBellButtonState();
}

class _NotificationBellButtonState extends State<NotificationBellButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final count = await sl<NotificationRepository>().getUnreadCount();
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {
      // The badge is optional; keep the last known count on failure.
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.pushNamed(context, AppRoutes.notificationPage);
    _loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _openNotifications,
      icon: Badge(
        isLabelVisible: _unreadCount > 0,
        label: Text(
          _unreadCount > 99 ? '99+' : '$_unreadCount',
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColor.kBadgeRed,
        child: SvgPicture.asset(
          widget.iconAsset,
          width: widget.iconSize,
          height: widget.iconSize,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
