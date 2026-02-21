import 'package:flutter/material.dart';
import 'package:kfon_subscriber/core/util/sizer.dart';
import 'package:kfon_subscriber/presentation/ui_component/common_app_bar.dart';

class AccountInformationPage extends StatelessWidget {
  AccountInformationPage({super.key});

  final TextStyle _dataTextStyle = TextStyle(
    fontFamily: 'General Sans',
    fontSize: 14.sp,
    color: const Color(0xFF0F1121),
    fontWeight: FontWeight.w500,
  );

  final TextStyle _labelStyle = TextStyle(
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
                          ? Text(
                        data.values.elementAt(index),
                        style: _dataTextStyle,
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

  @override
  Widget build(BuildContext context) {
    return CommonAppBar(
      actions: [
        IconButton(
          icon: Image.asset(
            'assets/icons/edit.png',
            height: 20.h,
            width: 20.w,
          ),
          onPressed: () {},
        ),
      ],
      onBackPressed: () => Navigator.pop(context),
      title: 'Account Information',
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            _buildDetailsItem('Personal Information', {
              'Subscriber ID': '#1234567897',
              'Username': 'Mr Rahul Mahajan',
              'Name': 'R mahajan',
              'Mobile No.': '+91 14254 12541',
              'Address': '123 Main Street,Kerla',
            }),
            _buildDetailsItem('Account Details', {
              'KYC/ID Proof': Row(
                spacing: 4,
                children: [
                  Image.asset(
                    'assets/icons/verified.png',
                    height: 14.h,
                    width: 14.w,
                  ),
                  Text('Verified', style: _dataTextStyle),
                ],
              ),
              'Subscription': 'Premium',
              'Status': Row(
                spacing: 3,
                children: [
                  CircleAvatar(radius: 6, backgroundColor: Colors.green),
                  Text('Active', style: _dataTextStyle),
                ],
              ),
              'Online Status': RichText(
                text: TextSpan(
                  text: 'Online ',
                  style: _dataTextStyle,
                  children: <TextSpan>[
                    TextSpan(text: '(2h ago)', style: _labelStyle),
                  ],
                ),
              ),
            }),
            _buildDetailsItem('Tax Information', {
              'PAN': 'ASHKJASG142',
              'GST': 'Not available',
            }),
            _buildDetailsItem('LNP Contact Details', {
              'Email': 'adsgshadjvfg@gmail.com',
              'Mobile No.': '+91 14254 12541',
              'LNP Name': 'R mahajan',
              'LNP Address': '123 Main Street,Kerla',
            }),
          ]
      ),
    );
  }
}
