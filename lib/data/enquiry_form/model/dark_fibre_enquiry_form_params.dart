import 'package:file_picker/file_picker.dart';

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

  Map<String, dynamic> toMap() {
    return {
      'firmName': firmName,
      'address': address,
      'firm_contact_number': firmContactNumber,
      'firm_email': email,
      'contact_person_name': contactPersonName,
      'contact_person_phone': contactPersonPhone,
      'contact_person_email': contactPersonEmail,
      'leasing_purpose': leasingPurpose,
      'telecom_service_provided_area': telecomServiceProvidedArea,
      'behalf_lease_company': behalfLeaseCompany,
      'internet_service_license_files': internetServiceLicenseFiles.map((file) => file.path).toList(),
      'experience_certificate_files': experienceCertificateFiles.map((file) => file.path).toList(),
      'covering_letter_files': coveringLetterFiles.map((file) => file.path).toList(),
      'route_lease_files': routeLeaseFiles.map((file) => file.path).toList(),
    };
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
