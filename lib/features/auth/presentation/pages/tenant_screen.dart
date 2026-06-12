import 'package:kfon_subscriber/core/constant/app_assets.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:kfon_subscriber/core/routes/app_routes.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        backgroundColor: AppColor.kPrimaryColor,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.loginBackground),
                fit: BoxFit.cover,
              ),
            ),
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
                          'Choose Your Circle',
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
                          'Select your state to continue with the login',
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
                            border: Border.all(color: const Color(0xFFE0E0E0)),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColor.kPrimaryColor,
                                size: 20.sp,
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (q) =>
                                      _bloc.add(SearchTenants(query: q)),
                                  decoration: InputDecoration(
                                    hintText: 'Search state',
                                    hintStyle: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFFAAAAAA),
                                      fontFamily: 'GeneralSans',
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
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
                              return SizedBox(
                                height: 300.h,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        state.errorMessage ??
                                            'Something went wrong',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13.sp,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 12.h),
                                      TextButton(
                                        onPressed: () =>
                                            _bloc.add(const LoadTenants()),
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            if (state.filteredTenants.isEmpty) {
                              return SizedBox(
                                height: 200.h,
                                child: Center(
                                  child: Text(
                                    'No states found',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E0E0),
                                ),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.filteredTenants.length,
                                separatorBuilder: (_, __) => Divider(
                                  height: 1,
                                  color: const Color(0xFFEEEEEE),
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
                                            ? AppColor.kPrimaryColor
                                                  .withOpacity(0.05)
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
                                                    ? AppColor.kPrimaryColor
                                                    : Colors.black87,
                                                fontFamily: 'GeneralSans',
                                              ),
                                            ),
                                          ),
                                          if (isSelected)
                                            Icon(
                                              Icons.check_circle,
                                              color: AppColor.kPrimaryColor,
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
                            child: SizedBox(
                              height: 52.h,
                              child: OutlinedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(
                                  Icons.arrow_back,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  'Back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeneralSans',
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  shape: const StadiumBorder(),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Continue
                          Expanded(
                            child: SizedBox(
                              height: 52.h,
                              child: ElevatedButton.icon(
                                onPressed: state.canContinue
                                    ? () async {
                                        await PreferenceUtils.setTenant(
                                          state.selectedTenant!.code,
                                          state.selectedTenant!.name,
                                        );
                                        Navigator.pushReplacementNamed(
                                          context,
                                          AppRoutes.login,
                                          arguments: {
                                            'tenantId':
                                                state.selectedTenant!.code,
                                            'tenantName':
                                                state.selectedTenant!.name,
                                          },
                                        );
                                      }
                                    : null,
                                icon: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    color: AppColor.kPrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'GeneralSans',
                                  ),
                                ),
                                label: const Icon(
                                  Icons.arrow_forward,
                                  color: AppColor.kPrimaryColor,
                                  size: 18,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.white
                                      .withOpacity(0.4),
                                  shape: const StadiumBorder(),
                                ),
                              ),
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
        ),
      ),
    );
  }
}
