import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/common/bloc/faq/faq_page_state.dart';
import 'package:kfon_subscriber/core/usecase/usecase.dart';
import 'package:kfon_subscriber/data/faq/model/faq_question.dart';

class FaqPageCubit extends Cubit<FaqPageState> {
  FaqPageCubit() : super(InitialState());

  Future<void> getQuestions({
    required String keyword,
    required UseCase useCase,
  }) async {
    try {
      emit(QuestionLoading());
      Either result = await useCase.call(param: keyword);
      result.fold(
        (error) {
          emit(GetQuestionsError(errorMessage: error));
        },
        (data) {
          emit(
            GetQuestionsSuccess(
              questions: data,
              showCategory: keyword.isEmpty ? true : false,
            ),
          );
        },
      );
    } catch (e) {
      emit(GetQuestionsError(errorMessage: e.toString()));
    }
  }

  Future<void> showInitialView(List<FaqQuestion> questions) async => emit(GetQuestionsSuccess(questions: questions, showCategory: true));

  Future<void> viewAllTopQuestions(List<FaqQuestion> questions) async => emit(GetQuestionsSuccess(questions: questions, showCategory: false));
}
