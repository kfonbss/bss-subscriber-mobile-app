import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/rating/rating_eligibility_manager.dart';
import 'package:kfon_subscriber/features/feedback/presentation/bloc/feedback_cubit.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('sends the rating and comment, then completes', () async {
    final sent = <Object>[];
    final cubit = FeedbackCubit(
      eligibility: RatingEligibilityManager.instance,
      send: (rating, comment) async {
        sent.addAll([rating, comment]);
        return const Right(unit);
      },
    );

    await cubit.submit(4, 'Good app');

    expect(sent, [4, 'Good app']);
    expect(cubit.state, isA<FeedbackSubmitted>());
  });

  test('a failed send shows the error and can be retried', () async {
    var attempts = 0;
    final cubit = FeedbackCubit(
      eligibility: RatingEligibilityManager.instance,
      send: (_, __) async {
        attempts++;
        return attempts == 1
            ? const Left(ServerFailure('star_rating is required'))
            : const Right(unit);
      },
    );

    await cubit.submit(5, '');
    expect(cubit.state, const FeedbackFailed('star_rating is required'));

    await cubit.submit(5, '');
    expect(cubit.state, isA<FeedbackSubmitted>());
  });
}
