import 'package:kfon_subscriber/data/enquiry_form/model/post_office_district_response.dart';

abstract class LnpEnquiryFormState {}

class GetPostOfficesDistrictLoading extends LnpEnquiryFormState {}

class GetPostOfficesDistrictSuccess extends LnpEnquiryFormState {
  final PostOfficeDistrictResponse response;
  GetPostOfficesDistrictSuccess({required this.response});
}

class GetPostOfficesDistrictError extends LnpEnquiryFormState {
  final String errorMessage;
  GetPostOfficesDistrictError({required this.errorMessage});
}


class ShowCompanyInformationForm extends LnpEnquiryFormState {}

class ShowPersonalInformationForm extends LnpEnquiryFormState {}

class ShowPreview extends LnpEnquiryFormState {}


class SubmitLnpFormLoading extends LnpEnquiryFormState {}

class SubmitLnpFormSuccess extends LnpEnquiryFormState {}

class SubmitLnpFormError extends LnpEnquiryFormState {
  final String errorMessage;
  SubmitLnpFormError({required this.errorMessage});
}

class LnpFormValidationError extends LnpEnquiryFormState {
  final String errorMessage;
  LnpFormValidationError({required this.errorMessage});
}



