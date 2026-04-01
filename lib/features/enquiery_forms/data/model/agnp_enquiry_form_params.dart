import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/lnp_enquiry_form.dart';

class AGNPEnquiryFormParams {
  final String name;
  final String contactName;
  final SIPStatus ispValue;
  final String mobileNumber;
  final String alternativeMobileNumber;
  final String landlineNumber;
  final String email;
  final String address;
  final String location;
  final String latitude;
  final String longitude;
  final String pinCode;
  final String postOffice;
  final String district;

  AGNPEnquiryFormParams({
    required this.name,
    required this.contactName,
    required this.ispValue,
    required this.mobileNumber,
    required this.alternativeMobileNumber,
    required this.landlineNumber,
    required this.email,
    required this.address,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.pinCode,
    required this.postOffice,
    required this.district
  });
  Map<String, dynamic> toMap() {
    return {
      'agnpName': name,
      'agnpContactName': contactName,
      'agnpAssocAnyOtherIsp': ispValue.name,
      'agnpMobileNumber': mobileNumber,
      'agnpAltrContactNumber': alternativeMobileNumber,
      'agnpLandlineNumber': landlineNumber,
      'agnpEmail': email,
      'agnpAddress': address,
      'agnpLocation': location,
      'agnpLatitude': latitude,
      'agnpLongitude': longitude,
      'agnpPincode': pinCode,
      'agnpPostoffice': postOffice,
      'agnpDistrict': district,
      'isActive': true
    };
  }
  Map<String, dynamic> geoGraphicInfoToMap() {
    return {
     'Latitude': latitude,
      'Longitude': longitude,
      'Pin Code': pinCode,
      'Post Office': postOffice,
      'District': district,
    };
  }
  Map<String, dynamic> companyInfoToMap() {
    return {
      'Name': name,
      'Contact Name': contactName,
      'Currently associated with any other ISP?': ispValue.name,
      'Mobile Number': mobileNumber,
      'Alternative Mobile Number': alternativeMobileNumber,
      'Landline Number': landlineNumber,
      'Email': email,
      'Address': address,
      'Location': location
    };
  }
}
