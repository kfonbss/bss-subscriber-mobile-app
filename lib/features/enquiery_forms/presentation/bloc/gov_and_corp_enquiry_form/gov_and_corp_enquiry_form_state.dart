abstract class GovAndCorpEnquiryFormState {}

class ShowLocationForm extends GovAndCorpEnquiryFormState {}

class ShowPersonalForm extends GovAndCorpEnquiryFormState {}

class ShowPreview extends GovAndCorpEnquiryFormState {}

class GovAndCorpFormSubmissionLoading extends GovAndCorpEnquiryFormState {}

class GovAndCorpFormSubmissionSuccess extends GovAndCorpEnquiryFormState {}

class GovAndCorpFormSubmissionError extends GovAndCorpEnquiryFormState {
  final String errorMessage;
  GovAndCorpFormSubmissionError({required this.errorMessage});
}

class GovAndCorpFormValidationError extends GovAndCorpEnquiryFormState {
  final String errorMessage;
  GovAndCorpFormValidationError({required this.errorMessage});
}




