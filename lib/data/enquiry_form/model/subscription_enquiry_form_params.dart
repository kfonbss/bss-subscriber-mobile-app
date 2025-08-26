class SubscriptionEnquiryFormParams {
  final String name;
  final String mobileNumber;
  final String ksebConsumerNo;
  final String address;
  final String pinCode;
  final String postOffice;
  final String district;
  final String referralCode;

  SubscriptionEnquiryFormParams({
    required this.name,
    required this.mobileNumber,
    required this.ksebConsumerNo,
    required this.address,
    required this.pinCode,
    required this.postOffice,
    required this.district,
    required this.referralCode
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile_number': mobileNumber,
      'kseb_consumer_no': ksebConsumerNo,
      'address': address,
      'pin_code': pinCode,
      'post_office': postOffice,
      'district': district,
      'referral_code': referralCode,
    };
  }

  Map<String, dynamic> getPreview() {
    return {
      'Name': name,
      'Mobile Number': mobileNumber,
      'KSEB Consumer No': ksebConsumerNo,
      'Address': address,
      'Pin Code': pinCode,
      'Post Office': postOffice,
      'District': district,
      'referral Code': referralCode,
    };
  }
}
