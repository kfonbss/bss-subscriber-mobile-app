import 'package:equatable/equatable.dart';

class PersonalInfo extends Equatable {
  final int subscriberId;
  final String username;
  final String name;
  final String mobileNo;
  final String address;

  const PersonalInfo({
    required this.subscriberId,
    required this.username,
    required this.name,
    required this.mobileNo,
    required this.address,
  });

  @override
  List<Object?> get props => [subscriberId, username, name, mobileNo, address];
}

class AccountInfo extends Equatable {
  final String kycStatus;
  final String subscriptionName;
  final String subscriptionStatus;
  final String onlineStatus;

  const AccountInfo({
    required this.kycStatus,
    required this.subscriptionName,
    required this.subscriptionStatus,
    required this.onlineStatus,
  });

  @override
  List<Object?> get props => [
    kycStatus,
    subscriptionName,
    subscriptionStatus,
    onlineStatus,
  ];
}

class TaxInfo extends Equatable {
  final String pan;
  final String gst;

  const TaxInfo({required this.pan, required this.gst});

  @override
  List<Object?> get props => [pan, gst];
}

class LnpInfo extends Equatable {
  final String lnpName;
  final String lnpEmail;
  final String lnpMobile;
  final String lnpAddress;

  const LnpInfo({
    required this.lnpName,
    required this.lnpEmail,
    required this.lnpMobile,
    required this.lnpAddress,
  });

  @override
  List<Object?> get props => [lnpName, lnpEmail, lnpMobile, lnpAddress];
}

class AccountInformationEntity extends Equatable {
  final PersonalInfo personalInfo;
  final AccountInfo accountInfo;
  final TaxInfo taxInfo;
  final LnpInfo lnpInfo;

  const AccountInformationEntity({
    required this.personalInfo,
    required this.accountInfo,
    required this.taxInfo,
    required this.lnpInfo,
  });

  @override
  List<Object?> get props => [personalInfo, accountInfo, taxInfo, lnpInfo];
}
