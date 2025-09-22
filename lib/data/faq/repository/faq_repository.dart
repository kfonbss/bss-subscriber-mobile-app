import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/data/faq/source/faq_api_service.dart';
import 'package:kfon_subscriber/domain/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class FaqRepositoryImp extends FaqRepository {
  @override
  Future<Either> getQuestions(String keyword) async {
    return await sl<FaqApiService>().getQuestions(keyword);
  }
}
