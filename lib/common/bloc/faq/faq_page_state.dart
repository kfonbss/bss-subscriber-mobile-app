import 'package:kfon_subscriber/data/faq/model/faq_question.dart';

abstract class FaqPageState {}

class InitialState extends FaqPageState {}

class QuestionLoading extends FaqPageState {}

class GetQuestionsSuccess extends FaqPageState {
  final List<FaqQuestion> questions;
  final bool showCategory;

  GetQuestionsSuccess({required this.questions,required this.showCategory});
}

class GetQuestionsError extends FaqPageState {
  final String errorMessage;

  GetQuestionsError({required this.errorMessage});
}
