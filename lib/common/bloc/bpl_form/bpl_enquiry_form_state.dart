import 'package:kfon_subscriber/data/enquiry_form/model/post_office_district_response.dart';

abstract class BplEnquiryFormState {}

class GetPostOfficesDistrictLoading extends BplEnquiryFormState {}

class GetPostOfficesDistrictSuccess extends BplEnquiryFormState {
  final PostOfficeDistrictResponse response;
  GetPostOfficesDistrictSuccess({required this.response});
}

class GetPostOfficesDistrictError extends BplEnquiryFormState {
  final String errorMessage;
  GetPostOfficesDistrictError({required this.errorMessage});
}


class ShowAddressInformationForm extends BplEnquiryFormState {}

class ShowPersonalInformationForm extends BplEnquiryFormState {}

class ShowPreview extends BplEnquiryFormState {}


class SubmitBplFormLoading extends BplEnquiryFormState {}

class SubmitBplFormSuccess extends BplEnquiryFormState {}

class SubmitBplFormError extends BplEnquiryFormState {
  final String errorMessage;
  SubmitBplFormError({required this.errorMessage});
}

class BplFormValidationError extends BplEnquiryFormState {
  final String errorMessage;
  BplFormValidationError({required this.errorMessage});
}



