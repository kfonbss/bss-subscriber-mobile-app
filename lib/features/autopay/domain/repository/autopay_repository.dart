import 'package:dartz/dartz.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/features/autopay/domain/entity/autopay_entity.dart';

abstract class AutopayRepository {
  Future<Either<Failure, AutopayStatus>> getStatus();

  /// Charges + content, and the mandate details once Autopay is enabled.
  Future<Either<Failure, AutopayQuoteEntity>> getQuote();

  /// Starts a mandate for [upiId]. Returns the server message.
  Future<Either<Failure, String>> initiate({required String upiId});

  /// Removes the active mandate. Returns the server message.
  Future<Either<Failure, String>> revoke();
}
