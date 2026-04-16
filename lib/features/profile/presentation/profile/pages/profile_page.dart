import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/dialog_util.dart';
import 'package:kfon_subscriber/core/util/extensions.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/features/profile/presentation/pages/security_settings_page.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_state.dart';
import 'package:kfon_subscriber/features/ticket/presentation/pages/tickets_page.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ── Header card ───────────────────────────────────────────────────────────
  static const _headerDecoration = BoxDecoration(
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
    color: AppColor.kCompletedGreen,
  );
  // BorderRadius.all(Radius.circular(21)) is const; .circular(21) is not.
  static const _statusBadgeDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(21)),
  );
  static final _statusBadgePadding =
      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h);

  // ── Section heading ───────────────────────────────────────────────────────
  static final _sectionHeadingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    color: Colors.black,
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
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            // ── Profile Header (from BLoC) ──
            BlocBuilder<ProfileBloc, ProfileState>(
              buildWhen: (previous, current) =>
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
                            style: const TextStyle(
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
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            tooltip: 'Retry',
                            onPressed: () => context
                                .read<ProfileBloc>()
                                .add(const FetchProfileRequested()),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 24.h),
            Text(l10n.account, style: _sectionHeadingStyle),
            SizedBox(height: 17),
            InkWell(
              onTap: () => Navigator.pushNamed(
                  context, AppRoutes.accountInformationPage),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: 'account_information',
                label: l10n.accountInformation,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => SecuritySettingsPage(
                    types: [
                      PasswordChangeEnum.bss,
                      PasswordChangeEnum.internet,
                    ],
                  ),
                ),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: 'security_settings',
                label: l10n.securitySettings,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TicketsPage()),
              ),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: 'my_tickets',
                label: l10n.myTickets,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.settingsPage),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: 'settings',
                label: l10n.settings,
                decoration: _listItemDecoration,
              ),
            ),
            InkWell(
              onTap: () => _showLogoutDialog(context),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: _ProfileListItem(
                image: 'logout',
                label: l10n.logout,
                decoration: _listItemDecoration,
                textColor: AppColor.kFailedRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = context.bssSubL10n;

    showModalBottomSheet(
      context: context,
      backgroundColor:
          context.isTablet ? Colors.transparent : AppColor.kMainBackgroundColor,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: context.isTablet
            ? BorderRadius.circular(24.w)
            : BorderRadius.vertical(top: Radius.circular(24.w)),
      ),
      builder: (BuildContext context) {
        final handleWidth = context.isTablet ? 42.0 * 1.2 : 42.w;
        final handleHeight = context.isTablet ? 6.0 * 1.2 : 6.h;
        final topPadding = context.isTablet ? 53.0 * 1.2 : 53.h;
        final horizontalPadding = context.isTablet ? 20.0 * 1.2 : 20.w;
        final bottomPadding = context.isTablet ? 30.0 * 1.2 : 30.h;
        final titleWidth = context.isTablet ? 193.0 * 1.2 : 193.w;
        final descWidth = context.isTablet ? 319.0 * 1.2 : 319.w;
        final buttonHeight = context.isTablet ? 52.0 * 1.2 : 52.h;
        final gapBetweenTitleDesc = context.isTablet ? 8.0 * 1.2 : 8.h;
        final gapBeforeButtons = context.isTablet ? 40.0 * 1.2 : 40.h;
        final gapBetweenButtons = context.isTablet ? 12.0 * 1.2 : 12.h;
        final handleTopMargin = context.isTablet ? 19.0 * 1.2 : 19.h;
        final maxWidth = context.isTablet ? 500.0 : double.infinity;

        Widget content = Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: topPadding,
                bottom:
                    bottomPadding + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: titleWidth,
                    child: Text(
                      l10n.logoutConfirmTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        color: AppColor.kTextSecondaryDark,
                        fontSize: context.isTablet ? 18.0 * 1.2 : 18.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: gapBetweenTitleDesc),
                  SizedBox(
                    width: descWidth,
                    child: Text(
                      l10n.logoutConfirmDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        color: AppColor.kSlateGrey,
                        fontSize: context.isTablet ? 12.0 * 1.2 : 12.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: gapBeforeButtons),
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: BlocConsumer<AuthBloc, AuthState>(
                      listenWhen: (previous, current) =>
                          current is LogoutSuccess || current is LogoutFailure,
                      buildWhen: (previous, current) =>
                          current is LogoutLoading ||
                          current is LogoutSuccess ||
                          current is LogoutFailure,
                      listener: (context, state) {
                        if (state is LogoutSuccess) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                            (Route<dynamic> route) => false,
                          );
                        } else if (state is LogoutFailure) {
                          DialogUtil().showCustomSnackbar(
                            context: context,
                            content: state.errorMessage,
                            backgroundColor: AppColor.kFailedRed,
                          );
                        }
                      },
                      builder: (context, state) {
                        final isLoading = state is LogoutLoading;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  context
                                      .read<AuthBloc>()
                                      .add(const LogoutRequested());
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.kFailedRed,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                AppColor.kFailedRed.withValues(alpha: 0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  l10n.logout,
                                  style: TextStyle(
                                    fontFamily: 'GeneralSans',
                                    fontSize: context.isTablet
                                        ? 14.0 * 1.2
                                        : 14.sp,
                                    fontWeight: FontWeight.w600,
                                    height: 1.3,
                                    letterSpacing: 0,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: gapBetweenButtons),
                  SizedBox(
                    width: double.infinity,
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromRGBO(0, 0, 0, 0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(
                          fontFamily: 'GeneralSans',
                          fontSize: context.isTablet ? 14.0 * 1.2 : 14.sp,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: handleTopMargin,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: handleWidth,
                  height: handleHeight,
                  decoration: const BoxDecoration(
                    color: AppColor.kDividerGrey,
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                  ),
                ),
              ),
            ),
          ],
        );

        if (context.isTablet) {
          return SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                  maxHeight: MediaQuery.sizeOf(context).height * 0.6,
                ),
                decoration: BoxDecoration(
                  color: AppColor.kMainBackgroundColor,
                  borderRadius: BorderRadius.circular(24.w),
                ),
                child: content,
              ),
            ),
          );
        }

        return SafeArea(top: false, child: content);
      },
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

  // Sizer values — fixed after MaterialApp.builder, computed once.
  static final double _height = 70.h;
  static final EdgeInsets _margin = EdgeInsets.only(bottom: 17.h);
  static final EdgeInsets _padding =
      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h);
  static final double _iconContainerSize = 38.w;
  static final double _iconContainerHeight = 38.h;
  static const _iconContainerPadding = EdgeInsets.all(9);
  static const _iconBgDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: AppColor.kIconContainerGrey,
  );
  // Default label style — used for all items except logout.
  static final _defaultLabelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
    height: 1.3,
    color: AppColor.kTextSecondaryDark,
  );
  // Pre-computed logout style — avoids copyWith per build.
  static final _logoutLabelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 14.sp,
    height: 1.3,
    color: AppColor.kFailedRed,
  );
  static final double _arrowSize = 16.sp;

  @override
  Widget build(BuildContext context) {
    final labelStyle = textColor == null ? _defaultLabelStyle : _logoutLabelStyle;

    return Container(
      margin: _margin,
      padding: _padding,
      height: _height,
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
                width: _iconContainerSize,
                height: _iconContainerHeight,
                padding: _iconContainerPadding,
                decoration: _iconBgDecoration,
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/$image.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(label, style: labelStyle),
            ],
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: _arrowSize,
            color: AppColor.kSlateGrey,
          ),
        ],
      ),
    );
  }
}
