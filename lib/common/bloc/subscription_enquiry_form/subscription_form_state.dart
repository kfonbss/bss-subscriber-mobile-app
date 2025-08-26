import 'package:kfon_subscriber/data/enquiry_form/model/post_office_district_response.dart';

abstract class SubscriptionFormState {}


class GetPostOfficesDistrictLoading extends SubscriptionFormState {}

class GetPostOfficesDistrictSuccess extends SubscriptionFormState {
  final PostOfficeDistrictResponse response;
  GetPostOfficesDistrictSuccess({required this.response});
}


class GetPostOfficesDistrictError extends SubscriptionFormState {
  final String errorMessage;
  GetPostOfficesDistrictError({required this.errorMessage});
}

class ShowForm extends SubscriptionFormState {}

class ShowPreview extends SubscriptionFormState {}

class SubmitSubscriptionFormLoading extends SubscriptionFormState {}

class SubmitSubscriptionFormSuccess extends SubscriptionFormState {}

class SubmitSubscriptionFormError extends SubscriptionFormState {
  final String errorMessage;
  SubmitSubscriptionFormError({required this.errorMessage});
}

class SubscriptionFormValidationError extends SubscriptionFormState {
  final String errorMessage;
  SubscriptionFormValidationError({required this.errorMessage});
}


