import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/constant/constant_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_state.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';
import 'package:kfon_subscriber/service_locator.dart';

class AccountInformationPage extends StatelessWidget {
  const AccountInformationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
      AccountInformationBloc(repository: sl<ProfileRepository>())
        ..add(const FetchAccountInformationRequested()),
      child: const _AccountInformationView(),
    );
  }
}

class _AccountInformationView extends StatelessWidget {
  const _AccountInformationView();

  // Static helper — does not use `this`, extracted so it is not an instance
  // closure allocation on every rebuild.
  static Widget _buildContent(BuildContext context, AccountInformationEntity info) {
    final l10n = context.bssSubL10n;
    final personal = info.personalInfo;
    final account = info.accountInfo;
    final tax = info.taxInfo;
    final lnp = info.lnpInfo;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        _DetailsCard(heading: l10n.personalInformation, data: {
          l10n.subscriberId: '#${personal.subscriberId}',
          l10n.username: personal.username,
          l10n.name: personal.name,
          l10n.mobileNo: personal.mobileNo,
          l10n.email: lnp.lnpEmail,
          l10n.address: personal.address,
        }),
        _DetailsCard(heading: l10n.accountDetails, data: {
          l10n.kycIdProof: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (account.kycStatus.toLowerCase() == 'verified')
                Image.asset(
                  'assets/icons/verified.png',
                  height: 14.h,
                  width: 14.w,
                ),
              Text(
                account.kycStatus.isNotEmpty ? account.kycStatus : '-',
                style: _DetailsCard._dataTextStyle,
              ),
            ],
          ),
          l10n.subscription:
              account.subscriptionName.isNotEmpty
                  ? account.subscriptionName
                  : '-',
          l10n.status: Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              CircleAvatar(
                radius: 6,
                backgroundColor:
                    account.subscriptionStatus.toLowerCase() == 'active'
                        ? AppColor.kCompletedGreen
                        : AppColor.kMediumGrey,
              ),
              Text(
                account.subscriptionStatus.isNotEmpty
                    ? account.subscriptionStatus
                    : '-',
                style: _DetailsCard._dataTextStyle,
              ),
            ],
          ),
          l10n.onlineStatus:
              account.onlineStatus.isNotEmpty ? account.onlineStatus : '-',
        }),
        _DetailsCard(heading: l10n.taxInformation, data: {
          l10n.pan: tax.pan.isNotEmpty ? tax.pan : l10n.notAvailable,
          l10n.gst: tax.gst.isNotEmpty ? tax.gst : l10n.notAvailable,
        }),
        _DetailsCard(heading: l10n.lnpContactDetails, data: {
          l10n.email: lnp.lnpEmail.isNotEmpty ? lnp.lnpEmail : '-',
          l10n.mobileNo: lnp.lnpMobile.isNotEmpty ? lnp.lnpMobile : '-',
          l10n.lnpName: lnp.lnpName.isNotEmpty ? lnp.lnpName : '-',
          l10n.lnpAddress: lnp.lnpAddress.isNotEmpty ? lnp.lnpAddress : '-',
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.bssSubL10n;

    return CommonAppBar(
      onBackPressed: () => Navigator.pop(context),
      title: l10n.accountInformation,
      body: BlocBuilder<AccountInformationBloc, AccountInformationState>(
        // Only rebuild when the state type changes — prevents spurious rebuilds
        // if the same state is emitted again.
        buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
        builder: (context, state) {
          if (state is AccountInformationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountInformationLoaded) {
            return _buildContent(context, state.accountInformation);
          } else if (state is AccountInformationError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'GeneralSans',
                        fontSize: 14.sp,
                        color: AppColor.kSlateGrey,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () => context.read<AccountInformationBloc>().add(
                        const FetchAccountInformationRequested(),
                      ),
                      child: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Details card ──────────────────────────────────────────────────────────────
// Extracted from the _buildDetailsItem instance helper so Flutter can track
// each card's identity and skip rebuilds independently.
class _DetailsCard extends StatelessWidget {
  final String heading;
  final Map<String, dynamic> data;

  const _DetailsCard({required this.heading, required this.data});

  // Sizer ratios are fixed after MaterialApp.builder — computed once as static final.
  static final TextStyle _dataTextStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    color: AppColor.kTextSecondaryDark,
    fontWeight: FontWeight.w500,
  );
  static final TextStyle _labelStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontSize: 14.sp,
    color: AppColor.kTextSecondaryDark,
    fontWeight: FontWeight.w400,
  );
  static final TextStyle _headingStyle = TextStyle(
    fontFamily: 'GeneralSans',
    fontWeight: FontWeight.w600,
    fontSize: 16.sp,
    color: Colors.black,
  );
  // EdgeInsets.all(8.w) uses Sizer — computed once as static final.
  static final EdgeInsets _rowPadding = EdgeInsets.all(8.w);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(heading, style: _headingStyle),
            Column(
              children: List.generate(
                data.length,
                (index) => Padding(
                  padding: _rowPadding,
                  child: Row(
                    spacing: 20,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.keys.elementAt(index), style: _labelStyle),
                      data.values.elementAt(index) is String
                          ? Flexible(
                              child: Text(
                                data.values.elementAt(index),
                                style: _dataTextStyle,
                                textAlign: TextAlign.end,
                              ),
                            )
                          : data.values.elementAt(index),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
