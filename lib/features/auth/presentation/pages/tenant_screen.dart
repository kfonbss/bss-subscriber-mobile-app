import 'package:kfon_subscriber/shared/widgets/common_text_field.dart';
import 'package:kfon_subscriber/shared/widgets/secondary_button.dart';
import 'package:kfon_subscriber/shared/widgets/primary_button.dart';
import 'package:kfon_subscriber/core/constant/app_brand.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/shared/widgets/login_background.dart';
import 'package:kfon_subscriber/shared/widgets/no_data_found.dart';
import 'package:kfon_subscriber/shared/widgets/retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../service_locator.dart';
import '../../domain/repository/tenant_repository.dart';
import '../bloc/tenant_bloc.dart';
import '../bloc/tenant_event.dart';
import '../bloc/tenant_state.dart';

class TenantScreen extends StatefulWidget {
  const TenantScreen({super.key});

  @override
  State<TenantScreen> createState() => _TenantScreenState();
}

class _TenantScreenState extends State<TenantScreen> {
  late final TenantBloc _bloc;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _bloc = TenantBloc(sl<TenantRepository>())..add(const LoadTenants());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bloc.close();
    super.dispose();
  }

  // No tenant is chosen yet, so the primary colour isn't known: start neutral
  // and cross-fade to the selected tenant's primary when one is tapped.
  static const _colorAnimationDuration = Duration(milliseconds: 600);

  // Before anything is tapped: the saved tenant's primary when coming back to
  // change tenant, or the neutral colour on first launch (no tenant yet).
  static Color get _unselectedColor => AppBrand.hasTenant
      ? AppColor.kPrimaryColor
      : AppColor.kTenantScreenBackground;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocSelector<TenantBloc, TenantState, String?>(
        selector: (state) => state.selectedTenant?.code,
        builder: (context, selectedCode) {
          return TweenAnimationBuilder<Color?>(
            tween: ColorTween(
              end: selectedCode == null
                  ? _unselectedColor
                  : AppColor.primaryFor(selectedCode),
            ),
            duration: _colorAnimationDuration,
            curve: Curves.easeInOutCubic,
            builder: (context, color, _) =>
                _buildScreen(context, color ?? _unselectedColor),
          );
        },
      ),
    );
  }

  Widget _buildScreen(BuildContext context, Color accent) {
    return Scaffold(
      backgroundColor: accent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          LoginBackground(color: accent),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 48.h),

                        // ── Title ──────────────────────────────
                        Text(
                          context.bssSubL10n.chooseYourCircle,
                          style: TextStyle(
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'GeneralSans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          context.bssSubL10n.selectStateToContinue,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white,
                            fontFamily: 'GeneralSans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 32.h),

                        // ── Search ─────────────────────────────
                        Container(
                          height: 52.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColor.kShimmerBase),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: accent, size: 20.sp),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: CommonTextField(
                                  hintText: context.bssSubL10n.searchState,
                                  textEditingController: _searchController,
                                  onTextChanged: (q) =>
                                      _bloc.add(SearchTenants(query: q)),
                                  fillColor: Colors.transparent,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                  hintStyle: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColor.kSilverGrey,
                                    fontFamily: 'GeneralSans',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // ── List ───────────────────────────────
                        BlocBuilder<TenantBloc, TenantState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return SizedBox(
                                height: 300.h,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            if (state.hasError) {
                              return RetryWidget(
                                textColor: Colors.white,
                                errorMessage:
                                    state.errorMessage ??
                                    context.bssSubL10n.somethingWentWrong,
                                onRetry: () => _bloc.add(const LoadTenants()),
                              );
                            }

                            if (state.filteredTenants.isEmpty) {
                              return NoDataFound(
                                textColor: Colors.white,
                                iconColor: Colors.white,
                                errorMessage: context.bssSubL10n.noStatesFound,
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColor.kShimmerBase,
                                ),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.filteredTenants.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1.h,
                                  color: AppColor.kLightBorderGrey,
                                  indent: 16.w,
                                  endIndent: 16.w,
                                ),
                                itemBuilder: (_, i) {
                                  final tenant = state.filteredTenants[i];
                                  final isSelected =
                                      state.selectedTenant?.id == tenant.id;

                                  return InkWell(
                                    onTap: () =>
                                        _bloc.add(SelectTenant(tenant: tenant)),
                                    borderRadius: BorderRadius.vertical(
                                      top: i == 0
                                          ? Radius.circular(12)
                                          : Radius.zero,
                                      bottom:
                                          i == state.filteredTenants.length - 1
                                          ? Radius.circular(12)
                                          : Radius.zero,
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 16.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.vertical(
                                          top: i == 0
                                              ? Radius.circular(12)
                                              : Radius.zero,
                                          bottom:
                                              i ==
                                                  state.filteredTenants.length -
                                                      1
                                              ? Radius.circular(12)
                                              : Radius.zero,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              tenant.name,
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w400,
                                                color: isSelected
                                                    ? accent
                                                    : Colors.black87,
                                                fontFamily: 'GeneralSans',
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: accent,
                                              size: 20.sp,
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),

                // ── Bottom buttons ─────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
                  child: BlocBuilder<TenantBloc, TenantState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          // Back
                          Expanded(
                            // Transparent over the tenant backdrop, white rule
                            // and label; borderRadius 999 for the stadium.
                            child: SecondaryButton(
                              label: context.bssSubL10n.back,
                              borderRadius: 999,
                              height: 52.h,
                              backgroundColor: Colors.transparent,
                              borderColor: Colors.white,
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onClicked: () => Navigator.pop(context),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'GeneralSans',
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Continue
                          Expanded(
                            child: PrimaryButton(
                              label: context.bssSubL10n.continueText,
                              isLoading: false,
                              borderRadius: 999,
                              height: 52.h,
                              backgroundColor: Colors.white,
                              foregroundColor: accent,
                              icon: Icon(Icons.arrow_forward, color: accent),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'GeneralSans',
                              ),
                              onClicked: state.canContinue
                                  ? () async {
                                      final tenant = state.selectedTenant!;
                                      await PreferenceUtils.setTenant(
                                        tenant.code,
                                        tenant.name,
                                      );
                                      AppBrand.setTenant(tenant.code);
                                      if (!context.mounted) return;
                                      Navigator.pushReplacementNamed(
                                        context,
                                        AppRoutes.login,
                                        arguments: {
                                          'tenantId': tenant.code,
                                          'tenantName': tenant.name,
                                        },
                                      );
                                    }
                                  : null,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
