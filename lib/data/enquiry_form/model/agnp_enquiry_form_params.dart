import 'package:kfon_subscriber/presentation/pages/enquiry_forms/lnp_enquiry_form.dart';

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
      'name': name,
      'contact_name': contactName,
      'isp_value': ispValue.name,
      'mobile_number': mobileNumber,
      'alternative_mobile_number': alternativeMobileNumber,
      'landline_number': landlineNumber,
      'email': email,
      'address': address,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'pin_code': pinCode,
      'post_office': postOffice,
      'district': district,
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
