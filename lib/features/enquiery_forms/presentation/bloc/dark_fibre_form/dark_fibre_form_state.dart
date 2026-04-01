import 'dart:ui';

abstract class DarkFibreFormState {}

class ShowCompanyInfoForm extends DarkFibreFormState {}

class ShowDocumentCollectionForm extends DarkFibreFormState {}

class ShowPreview extends DarkFibreFormState {}

class SubmitDarkFibreFormLoading extends DarkFibreFormState {}

class SubmitDarkFibreFormSuccess extends DarkFibreFormState {}

class SubmitDarkFibreFormError extends DarkFibreFormState {
  final String errorMessage;

  SubmitDarkFibreFormError({required this.errorMessage});
}

class DarkFibreFormMessage extends DarkFibreFormState {
  final String message;
  final Color color;

  DarkFibreFormMessage({required this.message,required this.color});
}
