abstract class CorporateFormState {}

class ShowForm extends CorporateFormState {}

class ShowPreview extends CorporateFormState {}

class SubmitCorporateFormLoading extends CorporateFormState {}

class SubmitCorporateFormSuccess extends CorporateFormState {}

class SubmitCorporateFormError extends CorporateFormState {
  final String errorMessage;

  SubmitCorporateFormError({required this.errorMessage});
}

class CorporateFormValidationError extends CorporateFormState {
  final String errorMessage;

  CorporateFormValidationError({required this.errorMessage});
}
