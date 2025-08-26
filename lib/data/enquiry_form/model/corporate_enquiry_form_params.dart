class CorporateEnquiryFormParams {
  final String companyName;
  final String contactPersonName;
  final String contactPersonPhoneNumber;
  final String email;
  final String address;
  final String companyType;
  final List<String> requiredServices;
  final String latitude;
  final String longitude;

  CorporateEnquiryFormParams({
    required this.companyName,
    required this.contactPersonName,
    required this.contactPersonPhoneNumber,
    required this.email,
    required this.address,
    required this.companyType,
    required this.requiredServices,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'contactName': contactPersonName,
      'contactNumber': contactPersonPhoneNumber,
      'email': email,
      'address': address,
      'companyType': companyType,
      'requiredServices': requiredServices,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory CorporateEnquiryFormParams.fromMap(Map<String, dynamic> map) {
    return CorporateEnquiryFormParams(
        companyName: map['companyName'],
        contactPersonName: map['contactPersonName'],
        contactPersonPhoneNumber: map['contactPersonPhoneNumber'],
        email: map['email'],
        address: map['address'],
        companyType: map['companyType'],
        requiredServices: map['requiredServices'],
        latitude: map['latitude'],
        longitude: map['longitude']
    );
  }

  Map<String, dynamic> getPreview() {
    return {
      'Company Name': companyName,
      'Contact Name': contactPersonName,
      'Contact Number': contactPersonPhoneNumber,
      'Email': email,
      'Company Location/Address': address,
      'Company Type': companyType,
      'Services required': requiredServices,
      'Latitude': latitude,
      'Longitude': longitude,
    };
  }
}
