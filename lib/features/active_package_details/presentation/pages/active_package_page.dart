import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:flutter/material.dart';
import 'package:kfon_subscriber/features/active_package_details/domain/repository/package_details_repository.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_bloc.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_event.dart';
import 'package:kfon_subscriber/features/active_package_details/presentation/bloc/package_details_state.dart';
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
  late PackageDetailsBloc _bloc;
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
        title: 'Active Package',
        onBackPressed: () => Navigator.of(context).pop(),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: BlocBuilder<PackageDetailsBloc, PackageDetailsState>(
            bloc: _bloc,
            buildWhen: (previous, current) => current is GetDataSuccess,
            builder: (context, state) {
              return state is GetDataSuccess
                  ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PackageInfoCard(entity: state.entity),
                      SizedBox(height: 24.h),
                      Text(
                        'Active Add-ons',
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColor.kTextSecondaryDark,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      ListView.builder(
                        itemCount: state.entity.activeAddOns.length,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return _AddOnTile(
                            title:
                                '+${state.entity.activeAddOns[index].serviceTypeName}   ₹399',
                            subtitle: state.entity.activeAddOns[index].label,
                            isActive: state.entity.activeAddOns[index].isActive,
                          );
                        },
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.kTextSecondaryDark,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'GeneralSans',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColor.kTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColor.kCompletedGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontFamily: 'GeneralSans',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.kCompletedGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
