import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/network/dio_client.dart';
import 'package:kfon_subscriber/data/faq/model/faq_question.dart';
import 'package:kfon_subscriber/service_locator.dart';

abstract class FaqApiService {
  Future<Either> getQuestions(String keyword);
}

class FaqApiServiceImp extends FaqApiService {
  @override
  Future<Either> getQuestions(String keyword) async {
    var response = await sl<DioClient>().get(
      ApiUrls.bplEnquiryFormURL,
      queryParameters: {'\keyword': keyword},
    );
    List<FaqQuestion> questions=[];
    for (int i = 0; i < 5; i++) {
      questions.add(FaqQuestion(question: 'How to create a account?',answer: 'Open the Tradebase app to get started and follow the steps. Tradebase doesn’t charge a fee to create or maintain your Tradebase account.'));
    }
    return Right(questions);
    // if (response.status == 'success') {
    //   return Right(response.data
    //       .map((i) => FaqQuestion.fromJson(i))
    //       .toList()
    //       .cast<FaqQuestion>());
    // } else {
    //   return Left(response.message);
    // }
  }
}
