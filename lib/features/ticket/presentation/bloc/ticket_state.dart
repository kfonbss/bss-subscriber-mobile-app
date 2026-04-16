import 'package:kfon_subscriber/features/ticket/domain/entity/add_note_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/submit_ticket_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/visibility_entity.dart';

sealed class TicketState {
  const TicketState();
}

class TicketInitial extends TicketState {
  const TicketInitial();
}

class SubjectLoading extends TicketState {
  const SubjectLoading();
}

class SubjectLoaded extends TicketState {
  final List<SubjectEntity> subjects;

  const SubjectLoaded({required this.subjects});
}

class PriorityLoading extends TicketState {
  const PriorityLoading();
}

class PriorityLoaded extends TicketState {
  final List<PriorityEntity> priorities;

  const PriorityLoaded({required this.priorities});
}

class FileSelected extends TicketState {
  const FileSelected();
}

class SubjectSelected extends TicketState {
  final SubjectEntity subject;

  const SubjectSelected({required this.subject});
}

class TicketSubmitting extends TicketState {
  const TicketSubmitting();
}

class TicketSubmitted extends TicketState {
  final SubmitTicketRespoEntity respoEntity;

  const TicketSubmitted({required this.respoEntity});
}

class TicketsLoading extends TicketState {
  final TicketsListResponseEntity? previousData;
  const TicketsLoading({this.previousData});
}

class TicketsRefreshing extends TicketState {
  final TicketsListResponseEntity currentData;
  const TicketsRefreshing({required this.currentData});
}

class TicketsLoaded extends TicketState {
  final TicketsListResponseEntity data;
  final bool isLoadingMore;
  final String? paginationError;

  const TicketsLoaded({
    required this.data,
    this.isLoadingMore = false,
    this.paginationError,
  });

  static const _clear = Object();

  TicketsLoaded copyWith({
    TicketsListResponseEntity? data,
    bool? isLoadingMore,
    Object? paginationError = _clear,
  }) {
    return TicketsLoaded(
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      paginationError: identical(paginationError, _clear)
          ? this.paginationError
          : paginationError as String?,
    );
  }
}

class VisibilityLoading extends TicketState {
  const VisibilityLoading();
}

class VisibilityLoaded extends TicketState {
  final List<VisibilityEntity> visibilities;

  const VisibilityLoaded({required this.visibilities});
}

class NoteSubmitting extends TicketState {
  const NoteSubmitting();
}

class NoteSubmitted extends TicketState {
  final AddNoteRespoEntity respoEntity;

  /// The original note text, carried through state so the UI can
  /// perform an optimistic update without relying on mutable page-level state.
  final String note;

  const NoteSubmitted({required this.respoEntity, required this.note});
}

class OnError extends TicketState {
  final String errorMessage;
  final TicketsListResponseEntity? previousData;

  const OnError({required this.errorMessage, this.previousData});
}
