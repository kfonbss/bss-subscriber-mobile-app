import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/constant/api_urls.dart';
import 'package:kfon_subscriber/core/error/failure.dart';
import 'package:kfon_subscriber/core/rating/rating_eligibility_manager.dart';
import 'package:kfon_subscriber/features/feedback/data/railwire_feedback_repository.dart';

sealed class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object?> get props => [];
}

class FeedbackIdle extends FeedbackState {
  const FeedbackIdle();
}

class FeedbackSubmitting extends FeedbackState {
  const FeedbackSubmitting();
}

class FeedbackSubmitted extends FeedbackState {
  const FeedbackSubmitted();
}

class FeedbackFailed extends FeedbackState {
  final String message;
  const FeedbackFailed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Sends a rating and comment to a backend.
typedef FeedbackSender =
    Future<Either<Failure, Unit>> Function(int rating, String comment);

/// Handles the app feedback sheet's submit and marks feedback as done, which
/// stops the automatic prompt. Only RailWire has a feedback API; elsewhere
/// submit completes locally.
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({RatingEligibilityManager? eligibility, FeedbackSender? send})
    : _eligibility = eligibility ?? RatingEligibilityManager.instance,
      _send =
          send ?? (ApiUrls.isRailwire ? RailwireFeedbackRepository.send : null),
      super(const FeedbackIdle());

  final RatingEligibilityManager _eligibility;
  final FeedbackSender? _send;

  Future<void> submit(int rating, String comment) async {
    if (state is FeedbackSubmitting || state is FeedbackSubmitted) return;
    emit(const FeedbackSubmitting());
    try {
      final send = _send;
      if (send != null) {
        // Not marked as done when sending fails, so the user can retry.
        final failure = (await send(
          rating,
          comment,
        )).fold<Failure?>((failure) => failure, (_) => null);
        if (failure != null) {
          if (!isClosed) emit(FeedbackFailed(failure.message));
          return;
        }
      }
      await _eligibility.recordSubmitted();
      if (!isClosed) emit(const FeedbackSubmitted());
    } catch (e) {
      if (!isClosed) emit(FeedbackFailed(e.toString()));
    }
  }
}
