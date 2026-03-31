class HomeEnquiryFormParams {
  final String firstName;
  final String lastName;
  final String pinCode;
  final String location;
  final String cusAddress;
  final String houseNo;
  final String cusState;
  final String cusCity;
  final String cusLocation;
  final String postOffice;
  final String latitude;
  final String longitude;
  final String mobileNumber;
  final String email;

  HomeEnquiryFormParams({
    required this.firstName,
    required this.lastName,
    required this.pinCode,
    required this.location,
    required this.cusAddress,
    required this.houseNo,
    required this.cusState,
    required this.cusCity,
    required this.cusLocation,
    required this.postOffice,
    required this.latitude,
    required this.longitude,
    required this.mobileNumber,
    required this.email
  });
  Map<String, dynamic> toMap() {
    return {
      "firstName":firstName,
      "lastName": lastName,
      "cusMobile": mobileNumber,
      "cusEmail": email,
      "cusAddress": cusAddress,
      "houseNo": houseNo,
      "cusState": cusState,
      "cusCity": cusCity,
      "cusLocation": cusLocation,
      "cusPincode": pinCode,
      "postOffice": postOffice,
      "location": location,
      "latitude": latitude,
      "longitude": longitude
    };
  }

  Map<String, dynamic> getPreview() {
    return {
      'First Name': firstName,
      'Last Name': lastName,
      'Pin Code': pinCode,
      'Location': location,
      'Mobile Number': mobileNumber,
      'Email': email
    };
  }
}
