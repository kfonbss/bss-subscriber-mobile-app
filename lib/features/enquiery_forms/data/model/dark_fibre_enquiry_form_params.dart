import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:kfon_subscriber/core/util/image_util.dart';

class DarkFibreEnquiryFormParams {
  final String firmName;
  final String address;
  final String firmContactNumber;
  final String email;
  final String contactPersonName;
  final String contactPersonPhone;
  final String contactPersonEmail;
  final String leasingPurpose;
  final List<PlatformFile> internetServiceLicenseFiles;
  final String telecomServiceProvidedArea;
  final List<PlatformFile> experienceCertificateFiles;
  final String behalfLeaseCompany;
  final List<PlatformFile> coveringLetterFiles;
  final List<PlatformFile> routeLeaseFiles;

  DarkFibreEnquiryFormParams({
    required this.firmName,
    required this.address,
    required this.firmContactNumber,
    required this.email,
    required this.contactPersonName,
    required this.contactPersonPhone,
    required this.contactPersonEmail,
    required this.leasingPurpose,
    required this.internetServiceLicenseFiles,
    required this.experienceCertificateFiles,
    required this.telecomServiceProvidedArea,
    required this.behalfLeaseCompany,
    required this.coveringLetterFiles,
    required this.routeLeaseFiles,
  });

  Future<FormData> toFormData() async {
    final imageUtil = ImageUtil();
    final internetServiceLicenseCopy = await imageUtil.convertImageToBase64(internetServiceLicenseFiles.first);
    final supportExperienceCertificate = await imageUtil.convertImageToBase64(experienceCertificateFiles.first);
    final coveringLetterCopy = await imageUtil.convertImageToBase64(coveringLetterFiles.first);
    final routeFormCopy = await imageUtil.convertImageToBase64(routeLeaseFiles.first);
    // MultipartFile internetServiceLicenseCopy=await MultipartFile.fromFile(internetServiceLicenseFiles.first.path!,filename: internetServiceLicenseFiles.first.path!.split('/').last);
    // MultipartFile supportExperienceCertificate=await MultipartFile.fromFile(experienceCertificateFiles.first.path!,filename: experienceCertificateFiles.first.path!.split('/').last);
    // MultipartFile coveringLetterCopy=await MultipartFile.fromFile(coveringLetterFiles.first.path!,filename: coveringLetterFiles.first.path!.split('/').last);
    // MultipartFile routeFormCopy=await MultipartFile.fromFile(routeLeaseFiles.first.path!,filename: routeLeaseFiles.first.path!.split('/').last);
       return FormData.fromMap({
      'firmName': firmName,
      'address': address,
      'firmContactNo': firmContactNumber,
      'firmEmail': email,
      'contactPersonName': contactPersonName,
      'contactMobileNo': contactPersonPhone,
      'contactEmail': contactPersonEmail,
      'leasePurpose': leasingPurpose,
      'telecomAreaCircle': telecomServiceProvidedArea,
      'behalfCompanyLease': behalfLeaseCompany,
      'internetServiceLicenseCopy': internetServiceLicenseCopy,
      'supportExperienceCertificate': supportExperienceCertificate,
      'coveringLetterCopy': coveringLetterCopy,
      'routeFormCopy': routeFormCopy,
    });
  }


  Map<String, dynamic> getCompanyInfoPreview() {
    return {
      'Firm Name': firmName,
      'Full Address': address,
      'Firm Phone Number': firmContactNumber,
      'Firm Email': email,
      'Contact Person Name': contactPersonName,
      'Contact Person Phone Number': contactPersonPhone,
      'Contact Person Email': contactPersonEmail,
      'Purpose Of Leasing': leasingPurpose
    };
  }

  Map<String, dynamic> getDocumentInfoPreview() {
    return {
      'Internet Service License': internetServiceLicenseFiles.map((file) => file).toList(),
      'Area/Circle where Telecom service is provided': telecomServiceProvidedArea,
      'Certificate in support of Experience': experienceCertificateFiles.map((file) => file).toList(),
      'For and on behalf Lease Company M/S': behalfLeaseCompany,
      'Covering Letter': coveringLetterFiles.map((file) => file).toList(),
      'Details Of the RouteLease copy': routeLeaseFiles.map((file) => file).toList(),
    };
  }
}
