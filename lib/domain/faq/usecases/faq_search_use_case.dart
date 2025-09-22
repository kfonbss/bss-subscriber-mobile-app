import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/usercase/usecase.dart';
import 'package:kfon_subscriber/domain/faq/repository/faq_repository.dart';
import 'package:kfon_subscriber/service_locator.dart';

class FaqSearchUseCase implements UseCase<Either, String> {
  @override
  Future<Either> call({String? param}) async {
    return await sl<FaqRepository>().getQuestions(param!);
  }
}
