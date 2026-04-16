import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_bloc.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_event.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/page_component/package_info_card.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_base.dart';
import 'package:kfon_subscriber/presentation/ui_component/shimmer/shimmer_box.dart';
import 'package:kfon_subscriber/service_locator.dart';

class ActivePackagePage extends StatefulWidget {
  final String subscriberUuid;
  const ActivePackagePage({super.key, required this.subscriberUuid});

  @override
  State<ActivePackagePage> createState() => _ActivePackagePageState();
}

class _ActivePackagePageState extends State<ActivePackagePage> {
  static final _sectionHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    color: AppColor.kTextSecondaryDark,
  );

  late PackageDetailsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = PackageDetailsBloc(repository: sl<PackageDetailsRepository>());
    _bloc.add(GetActivePackageDetails(subscriberUuid: widget.subscriberUuid));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PackageDetailsBloc, PackageDetailsState>(
      bloc: _bloc,
      listenWhen: (prev, curr) => curr is GetDataFailure,
      listener: (context, state) {
        if (state is GetDataFailure) {
          DialogUtil().showMessage(state.errorMessage, context);
        }
      },
      child: CommonAppBar(
        title: context.bssSubL10n.activePackageTitle,
        onBackPressed: () => Navigator.of(context).pop(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocBuilder<PackageDetailsBloc, PackageDetailsState>(
            bloc: _bloc,
            builder: (context, state) {
              return state is GetDataSuccess
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PackageInfoCard(entity: state.entity),
                      SizedBox(height: 24.h),
                      Text(
                        context.bssSubL10n.activeAddOns,
                        style: _sectionHeadingStyle,
                      ),
                      SizedBox(height: 12.h),
                      Column(
                        children: [
                          for (final addOn in state.entity.activeAddOns)
                            _AddOnTile(
                              title: context.bssSubL10n.addonServiceTitle(
                                addOn.serviceTypeName,
                                addOn.packageValue,
                              ),
                              subtitle: addOn.label,
                              isActive: addOn.isActive,
                            ),
                        ],
                      ),
                    ],
                  )
                  : AppShimmer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: double.infinity, height: 190.h),
                        const SizedBox(height: 60),
                        ShimmerBox(width: double.infinity, height: 70.h),
                        const SizedBox(height: 16),
                        ShimmerBox(width: double.infinity, height: 70.h),
                        const SizedBox(height: 16),
                        ShimmerBox(width: double.infinity, height: 70.h),
                      ],
                    ),
                  );
            },
          ),
        ),
      ),
    );
  }
}

class _AddOnTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isActive;

  const _AddOnTile({
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  static const _shadowColor = Color(0x0A000000);   // black @ 4% opacity
  static const _activeBadgeBg = Color(0x1A1B993C); // kCompletedGreen @ 10% opacity

  // BorderRadius.circular(16) is not const; use the equivalent all() form.
  static const _tileDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: _shadowColor,
        blurRadius: 10,
        offset: Offset(0, 4),
      ),
    ],
  );
  static final _titleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kTextSecondaryDark,
  );
  static final _subtitleStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    color: AppColor.kTextSecondary,
  );
  static final _badgeTextStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColor.kCompletedGreen,
  );
  static final _badgePadding =
      EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: _tileDecoration,
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: AppColor.kPrimaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.language_rounded,
              size: 24.w,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _titleStyle),
                SizedBox(height: 2.h),
                Text(subtitle, style: _subtitleStyle),
              ],
            ),
          ),

          Container(
            padding: _badgePadding,
            decoration: const BoxDecoration(
              color: _activeBadgeBg,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Text(
              isActive
                  ? context.bssSubL10n.activeStatus
                  : context.bssSubL10n.inactiveStatus,
              style: _badgeTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
