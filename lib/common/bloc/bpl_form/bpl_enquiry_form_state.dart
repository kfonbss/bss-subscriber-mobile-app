abstract class BplEnquiryFormState {}

class GetPostOfficesDistrictLoading extends BplEnquiryFormState {}

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



