import 'package:dartz/dartz.dart';

abstract class FaqRepository{
  Future<Either> getQuestions(String keyword);
}