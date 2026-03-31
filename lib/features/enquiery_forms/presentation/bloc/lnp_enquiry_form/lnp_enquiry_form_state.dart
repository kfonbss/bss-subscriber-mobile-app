abstract class LnpEnquiryFormState {}

class GetPostOfficesDistrictLoading extends LnpEnquiryFormState {}

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



