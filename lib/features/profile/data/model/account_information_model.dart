import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';

class AccountInformationModel extends AccountInformationEntity {
  const AccountInformationModel({
    required super.personalInfo,
    required super.accountInfo,
    required super.taxInfo,
    required super.lnpInfo,
  });

  factory AccountInformationModel.fromJson(Map<String, dynamic> json) {
    return AccountInformationModel(
      personalInfo: _parsePersonalInfo(json['personalInfo'] ?? {}),
      accountInfo: _parseAccountInfo(json['accountInfo'] ?? {}),
      taxInfo: _parseTaxInfo(json['taxInfo'] ?? {}),
      lnpInfo: _parseLnpInfo(json['lnpInfo'] ?? {}),
    );
  }

  static PersonalInfo _parsePersonalInfo(Map<String, dynamic> json) {
    return PersonalInfo(
      subscriberId: json['subscriberId'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
    );
  }

  static AccountInfo _parseAccountInfo(Map<String, dynamic> json) {
    return AccountInfo(
      kycStatus: json['kycStatus'] ?? '',
      subscriptionName: json['subscriptionName'] ?? '',
      subscriptionStatus: json['subscriptionStatus'] ?? '',
      onlineStatus: json['onlineStatus'] ?? '',
    );
  }

  static TaxInfo _parseTaxInfo(Map<String, dynamic> json) {
    return TaxInfo(pan: json['pan'] ?? '', gst: json['gst'] ?? '');
  }

  static LnpInfo _parseLnpInfo(Map<String, dynamic> json) {
    return LnpInfo(
      lnpName: json['lnpName'] ?? '',
      lnpEmail: json['lnpEmail'] ?? '',
      lnpMobile: json['lnpMobile'] ?? '',
      lnpAddress: json['lnpAddress'] ?? '',
    );
  }
}
