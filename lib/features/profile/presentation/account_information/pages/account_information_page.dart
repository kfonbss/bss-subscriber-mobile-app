import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_bloc.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_state.dart';
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

  static final TextStyle _dataTextStyle = TextStyle(
    fontFamily: 'General Sans',
    fontSize: 14.sp,
    color: const Color(0xFF0F1121),
    fontWeight: FontWeight.w500,
  );

  static final TextStyle _labelStyle = TextStyle(
    fontFamily: 'General Sans',
    fontSize: 14.sp,
    color: const Color(0xFF0F1121),
    fontWeight: FontWeight.w400,
  );

  Widget _buildDetailsItem(String heading, Map<String, dynamic> data) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Text(
              heading,
              style: TextStyle(
                fontFamily: 'General Sans',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
            Column(
              children: List.generate(
                data.length,
                (index) => Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Row(
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

  Widget _buildContent(AccountInformationEntity info) {
    final personal = info.personalInfo;
    final account = info.accountInfo;
    final tax = info.taxInfo;
    final lnp = info.lnpInfo;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20),
      children: [
        _buildDetailsItem('Personal Information', {
          'Subscriber ID': '#${personal.subscriberId}',
          'Username': personal.username,
          'Name': personal.name,
          'Mobile No.': personal.mobileNo,
          'Address': personal.address,
        }),
        _buildDetailsItem('Account Details', {
          'KYC/ID Proof': Row(
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
                style: _dataTextStyle,
              ),
            ],
          ),
          'Subscription':
              account.subscriptionName.isNotEmpty
                  ? account.subscriptionName
                  : '-',
          'Status': Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 3,
            children: [
              CircleAvatar(
                radius: 6,
                backgroundColor:
                    account.subscriptionStatus.toLowerCase() == 'active'
                        ? Colors.green
                        : Colors.grey,
              ),
              Text(
                account.subscriptionStatus.isNotEmpty
                    ? account.subscriptionStatus
                    : '-',
                style: _dataTextStyle,
              ),
            ],
          ),
          'Online Status':
              account.onlineStatus.isNotEmpty ? account.onlineStatus : '-',
        }),
        _buildDetailsItem('Tax Information', {
          'PAN': tax.pan.isNotEmpty ? tax.pan : 'Not available',
          'GST': tax.gst.isNotEmpty ? tax.gst : 'Not available',
        }),
        _buildDetailsItem('LNP Contact Details', {
          'LNP Name': lnp.lnpName.isNotEmpty ? lnp.lnpName : '-',
          'Email': lnp.lnpEmail.isNotEmpty ? lnp.lnpEmail : '-',
          'Mobile No.': lnp.lnpMobile.isNotEmpty ? lnp.lnpMobile : '-',
          'LNP Address': lnp.lnpAddress.isNotEmpty ? lnp.lnpAddress : '-',
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      // actions: [
      //   IconButton(
      //     icon: Image.asset('assets/icons/edit.png', height: 20.h, width: 20.w),
      //     onPressed: () {},
      //   ),
      // ],
      onBackPressed: () => Navigator.pop(context),
      title: 'Account Information',
      body: BlocBuilder<AccountInformationBloc, AccountInformationState>(
        builder: (context, state) {
          if (state is AccountInformationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AccountInformationLoaded) {
            return _buildContent(state.accountInformation);
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
                        fontFamily: 'General Sans',
                        fontSize: 14.sp,
                        color: const Color(0xFF67697A),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed:
                          () => context.read<AccountInformationBloc>().add(
                            const FetchAccountInformationRequested(),
                          ),
                      child: const Text('Retry'),
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
