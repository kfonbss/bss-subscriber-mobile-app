import 'package:kfon_subscriber/data/enquiry_form/model/post_office_district_response.dart';

abstract class AGNPFormState {}


class GetPostOfficesDistrictLoading extends AGNPFormState {}

class GetPostOfficesDistrictSuccess extends AGNPFormState {
  final PostOfficeDistrictResponse response;
  GetPostOfficesDistrictSuccess({required this.response});
}


class GetPostOfficesDistrictError extends AGNPFormState {
  final String errorMessage;
  GetPostOfficesDistrictError({required this.errorMessage});
}

class ShowCompanyInformationForm extends AGNPFormState {}

class ShowGeographicInformationForm extends AGNPFormState {}

class ShowPreview extends AGNPFormState {}

class SubmitAGNPFormLoading extends AGNPFormState {}

class SubmitAGNPFormSuccess extends AGNPFormState {}

class SubmitAGNPFormError extends AGNPFormState {
  final String errorMessage;
  SubmitAGNPFormError({required this.errorMessage});
}

class SubscriptionFormValidationError extends AGNPFormState {
  final String errorMessage;
  SubscriptionFormValidationError({required this.errorMessage});
}


