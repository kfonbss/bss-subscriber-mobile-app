
class BplEnquiryFormParams {
  final String rationCardHolderName;
  final String rationCardHolderMob;
  final String ksebConsumerNo;
  final String aadharCardNumber;
  final String address;
  final String pinCode;
  final String postOffice;
  final String district;
  final String referralCode;

  BplEnquiryFormParams({
    required this.rationCardHolderName,
    required this.rationCardHolderMob,
    required this.ksebConsumerNo,
    required this.aadharCardNumber,
    required this.address,
    required this.pinCode,
    required this.postOffice,
    required this.district,
    required this.referralCode,
  });
  Map<String, dynamic> toMap() {
    return {
      'ration_card_holder_name': rationCardHolderName,
      'ration__card_holder_mob': rationCardHolderMob,
      'kseb_consumer_no': ksebConsumerNo,
      'aadhar_card_number': aadharCardNumber,
      'address': address,
      'pin_code': pinCode,
      'post_office': postOffice,
      'district': district,
      'referral_code': referralCode,
    };
  }

  Map<String, dynamic> personalInfoToMap() {
    return {
      'Ration Card Holder Name': rationCardHolderName,
      'Ration Card Holder Mobile Number': rationCardHolderMob,
      'KSEB Consumer No': ksebConsumerNo,
      'Aadhar Card Number': aadharCardNumber,
    };
  }

  Map<String, dynamic> addressInfoToMap() {
    return {
      'Installation Address': address,
      'Pin Code': pinCode,
      'Post Office': postOffice,
      'District': district,
      'Referral Code': referralCode
    };
  }
}
