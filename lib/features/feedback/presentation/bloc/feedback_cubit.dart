import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/rating/rating_eligibility_manager.dart';

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

/// Handles the app feedback sheet's submit. There is no backend call: submit
/// completes locally and marks feedback as done, which stops the automatic
/// prompt.
class FeedbackCubit extends Cubit<FeedbackState> {
  FeedbackCubit({RatingEligibilityManager? eligibility})
    : _eligibility = eligibility ?? RatingEligibilityManager.instance,
      super(const FeedbackIdle());

  final RatingEligibilityManager _eligibility;

  Future<void> submit(int rating, String comment) async {
    if (state is FeedbackSubmitting || state is FeedbackSubmitted) return;
    emit(const FeedbackSubmitting());
    try {
      await _eligibility.recordSubmitted();
      if (!isClosed) emit(const FeedbackSubmitted());
    } catch (e) {
      if (!isClosed) emit(FeedbackFailed(e.toString()));
    }
  }
}
