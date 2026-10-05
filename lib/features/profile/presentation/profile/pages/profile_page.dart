import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/pages/future_recharge_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/tickets_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/common_app_bar.dart';
import 'package:kfon_subscriber/core/constant/app_assets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Header card ───────────────────────────────────────────────────────────
  static get _headerDecoration => BoxDecoration(
    color: AppColor.kPrimaryColor,
    borderRadius: BorderRadius.all(Radius.circular(12)),
  );
  static final _headerPadding = EdgeInsets.symmetric(horizontal: 16.w);
  static final double _headerHeight = 100.h;
  static final _nameStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
    height: 1.3,
    color: Colors.white,
  );
  static final _subscriberIdStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    fontSize: 12.sp,
    height: 1.6,
    color: Colors.white,
  );
  static final _statusStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w500,
    fontSize: 9.sp,
    height: 1.6,
    color: AppColor.kProfileActiveGreen,
  );
  // BorderRadius.all(Radius.circular(21)) is const; .circular(21) is not.
  static const _statusBadgeDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(21)),
  );
  static final _statusBadgePadding = EdgeInsets.symmetric(
    horizontal: 6.w,
    vertical: 2.h,
  );

  // ── Section heading ───────────────────────────────────────────────────────
  static final _sectionHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    height: 1.3,
    color: AppColor.kTextSecondaryDark,
  );

  // ── List decoration (shared across all items) ─────────────────────────────
  static const _listItemDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(12)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColor.kinputFiledLightBorder, width: 1),
    ),
  );

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const FetchProfileRequested());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      title: l10n.myProfile,
      centerTitle: false,
      titleFontSize: 20.sp,
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ProfileBloc>().add(const FetchProfileRequested());
        },
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            // ── Profile Header (from BLoC) ──
            BlocBuilder<ProfileBloc, ProfileState>(
              buildWhen:
                  (previous, current) =>
                      current is ProfileLoaded ||
                      current is ProfileError ||
                      current is ProfileLoading,
              builder: (context, state) {
                String name = l10n.loadingText;
                String subscriberId = '';
                String status = '';

                if (state is ProfileLoaded) {
                  name = state.profile.name;
                  subscriberId = state.profile.subscriberId.toString();
                  status = state.profile.status;
                } else if (state is ProfileError) {
                  name = l10n.somethingWentWrong;
                }

                return Container(
                  height: _headerHeight,
                  decoration: _headerDecoration,
                  child: Padding(
                    padding: _headerPadding,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: Colors.white,
                          child: Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColor.kPrimaryColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4,
                            children: [
                              Text(name, style: _nameStyle),
                              if (subscriberId.isNotEmpty)
                                Text(
                                  l10n.idLabel(subscriberId),
                                  style: _subscriberIdStyle,
                                ),
                              if (status.isNotEmpty)
                                Container(
                                  padding: _statusBadgePadding,
                                  decoration: _statusBadgeDecoration,
                                  child: Text(status, style: _statusStyle),
                                ),
                            ],
                          ),
                        ),
                        if (state is ProfileError)
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            tooltip: context.bssSubL10n.retry,
                            onPressed:
                                () => context.read<ProfileBloc>().add(
                                  const FetchProfileRequested(),
                                ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(l10n.account, style: _sectionHeadingStyle),
            SizedBox(height: 17.h),
            InkWell(
              onTap:
                  () => Navigator.pushNamed(
                    context,
                    AppRoutes.accountInformationPage,
                  ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: AppAssets.accountInformation,
                label: l10n.accountInformation,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder:
                          (context) => SecuritySettingsPage(
                            types: [
                              PasswordChangeEnum.bss,
                              PasswordChangeEnum.internet,
                            ],
                          ),
                    ),
                  ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: AppAssets.securitySettings,
                label: l10n.securitySettings,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TicketsPage(),
                    ),
                  ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: AppAssets.myTickets,
                label: l10n.myTickets,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FutureRechargePage(),
                    ),
                  ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: AppAssets.myRechargesIcon,
                label: l10n.futureRecharges,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap: () => Navigator.pushNamed(context, AppRoutes.settingsPage),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: AppAssets.settings,
                label: l10n.settings,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap: () => DialogUtil().showLogoutDialog(context),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: AppAssets.logout,
                label: l10n.logout,
                decoration: _listItemDecoration,
                textColor: AppColor.kLogoutRed,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile list item ─────────────────────────────────────────────────────────
// Extracted from _createAccountListItems so Flutter can track element identity.
class _ProfileListItem extends StatelessWidget {
  final String image;
  final String label;
  final BoxDecoration decoration;
  final Color? textColor;

  const _ProfileListItem({
    required this.image,
    required this.label,
    required this.decoration,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLogout = textColor != null;

    return Container(
      margin: EdgeInsets.only(bottom: 17.h),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 16.h,
      ),
      height: 70.h,
      decoration: decoration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 38.h,
                padding:  EdgeInsets.all(9),
                decoration:
                     BoxDecoration(
                      shape: BoxShape.circle,
                      color:isLogout ? AppColor.kLogoutIconBg:AppColor.kIconBackground,
                    ),
                child: Center(
                  child: SvgPicture.asset(
                    image,
                    colorFilter: ColorFilter.mode(
                      isLogout ? AppColor.kLogoutRed : AppColor.kPrimaryColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(label, style: TextStyle(
                fontFamily: 'GeneralSans',
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
                height: 1.3,
                color: isLogout ?AppColor.kLogoutRed:AppColor.kTextSecondaryDark,
              ) ),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16.sp,
            color: AppColor.kSlateGrey,
          ),
        ],
      ),
    );
  }
}
