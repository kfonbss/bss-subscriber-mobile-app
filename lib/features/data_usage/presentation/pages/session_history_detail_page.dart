import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/features/data_usage/domain/entity/data_usage_entity.dart';
import 'package:kfon_subscriber/features/data_usage/presentation/pages/data_usage_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class SessionHistoryDetailPage extends StatelessWidget {
  final SessionEntity session;

  const SessionHistoryDetailPage({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final titleDateFormat = DateFormat('dd MMM yyyy HH:mm a');

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: titleDateFormat.format(session.startTime),
      scaffoldColor: AppColor.kMainBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SessionCard(session: session),
        ),
      ),
    );
  }
}
