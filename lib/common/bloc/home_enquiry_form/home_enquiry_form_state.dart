abstract class HomeEnquiryFormState {}

class ShowNameForm extends HomeEnquiryFormState {}

class ShowLocationForm extends HomeEnquiryFormState {}

class ShowContactForm extends HomeEnquiryFormState {}

class ShowPreview extends HomeEnquiryFormState {}

class HomeFormSubmissionLoading extends HomeEnquiryFormState {}

class HomeFormSubmissionSuccess extends HomeEnquiryFormState {}

class HomeFormSubmissionError extends HomeEnquiryFormState {
  final String errorMessage;
  HomeFormSubmissionError({required this.errorMessage});
}

class HomeFormValidationError extends HomeEnquiryFormState {
  final String errorMessage;
  HomeFormValidationError({required this.errorMessage});
}




