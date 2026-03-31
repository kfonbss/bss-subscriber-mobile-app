import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kfon_subscriber/core/util/image_util.dart';
import 'package:kfon_subscriber/features/enquiery_forms/presentation/pages/lnp_enquiry_form.dart';

class LNPEnquiryFormParams {
  final String companyName;
  final String partnerName;
  final SIPStatus ispValue;
  final String mobileNumber;
  final String landlineNumber;
  final String email;
  final String address;
  final String location;
  final String latitude;
  final String longitude;
  final String pinCode;
  final String postOffice;
  final String district;
  final List<PlatformFile> selectedFiles;
  final String totalCableTvSubscriberCount;
  final String totalInternetSubscriberCount;
  final String totalFiberCount;
  final String createdBy;

  LNPEnquiryFormParams({
    required this.companyName,
    required this.partnerName,
    required this.ispValue,
    required this.mobileNumber,
    required this.landlineNumber,
    required this.email,
    required this.address,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.pinCode,
    required this.postOffice,
    required this.district,
    required this.selectedFiles,
    required this.totalCableTvSubscriberCount,
    required this.totalInternetSubscriberCount,
    required this.totalFiberCount,
    required this.createdBy,
  });

  Future<FormData> toFormData() async {
    String partnerCableTvRegCopy = await ImageUtil().convertImageToBase64(
      selectedFiles.first,
    );
    // MultipartFile routeFormCopy=await MultipartFile.fromFile(selectedFiles.first.path!,filename: selectedFiles.first.path!.split('/').last);
    return FormData.fromMap({
      'partnerCompanyName': companyName,
      'partnerName': partnerName,
      'partnerAssocAnyOtherIsp': ispValue.name,
      'partnerMobile': mobileNumber,
      'partnerPhone': landlineNumber,
      'partnerEmail': email,
      'partnerAddress': address,
      'partnerLocation': location,
      'partnerLatitude': latitude,
      'partnerLongitude': longitude,
      'partnerPincode': pinCode,
      'partnerPostOffice': postOffice,
      'district': district,
      'partnerCableTvRegCopy': partnerCableTvRegCopy,
      'partnerCableTvSubCount': totalCableTvSubscriberCount,
      'partnerInternetSubCount': totalInternetSubscriberCount,
      'partnerNetworkQty': totalFiberCount,
      'createdByEmpName': createdBy,
    });
  }

  Map<String, dynamic> personalInfoToMap() {
    return {
      'Mobile Number': mobileNumber,
      'Landline Number': landlineNumber,
      'Email': email,
      'Address': address,
      'Location': location,
      'Latitude': latitude,
      'Longitude': longitude,
      'Pin Code': pinCode,
      'Post Office': postOffice,
      'district': district,
      'CableTV Registration License':
          selectedFiles.map((file) => file).toList(),
      'Total Cable Tv Subscriber Count': totalCableTvSubscriberCount,
      'Total Internet Subscriber Count': totalInternetSubscriberCount,
      'Total Fiber Count': totalFiberCount,
      'Created By': createdBy,
    };
  }

  Map<String, dynamic> companyInfoToMap() {
    return {
      'Company Name': companyName,
      'Partner Name': partnerName,
      'Currently associated with any other ISP?': ispValue.name,
    };
  }
}
