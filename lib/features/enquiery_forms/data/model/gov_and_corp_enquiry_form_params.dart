class GovAndCorpEnquiryFormParams {
  final String firstName;
  final String lastName;
  final String mobileNumber;
  final String email;
  final String companyName;
  final String pinCode;
  final String industry;
  final String service;

  GovAndCorpEnquiryFormParams({
    required this.firstName,
    required this.lastName,
    required this.mobileNumber,
    required this.email,
    required this.companyName,
    required this.pinCode,
    required this.industry,
    required this.service,
  });
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'mobileNumber': mobileNumber,
      'email': email,
      'companyName': companyName,
      'pinCode': pinCode,
      'industry': industry,
      'service': service,
    };
  }

  Map<String, dynamic> getPreview() {
    return {
      'First Name': firstName,
      'Last Name': lastName,
      'Mobile Number': mobileNumber,
      'Email': email,
      'Company Name': companyName,
      'Pin Code': pinCode,
      'Industry': industry,
      'Service': service,
    };
  }
}
