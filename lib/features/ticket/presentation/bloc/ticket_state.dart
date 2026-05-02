import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/add_note_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/priority_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/subject_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/submit_ticket_respo_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/ticket_category_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/visibility_entity.dart';

sealed class TicketState {
  const TicketState();
}

class TicketInitial extends TicketState {
  const TicketInitial();
}

/// Master data for create-ticket pickers (subjects, categories, priorities).
/// Kept in one state so concurrent loads (e.g. category + subject) do not
/// overwrite each other.
class TicketMasterDataState extends TicketState with EquatableMixin {
  static const _unset = Object();

  final List<SubjectEntity> subjects;
  final bool subjectsLoading;
  final String? subjectsError;

  final List<TicketCategoryEntity> categories;
  final bool categoriesLoading;
  final String? categoriesError;

  final List<PriorityEntity> priorities;
  final bool prioritiesLoading;
  final String? prioritiesError;

  final SubjectEntity? selectedSubject;
  final TicketCategoryEntity? selectedCategory;

  /// Resolved UUID of the customer type matching the user's role code.
  /// Null until [LoadCustomerTypeId] completes.
  final String? customerTypeId;

  /// Bumps when attachments change so [BlocBuilder]s can rebuild without a
  /// separate state that would drop master data.
  final int fileUiEpoch;

  const TicketMasterDataState({
    this.subjects = const [],
    this.subjectsLoading = false,
    this.subjectsError,
    this.categories = const [],
    this.categoriesLoading = false,
    this.categoriesError,
    this.priorities = const [],
    this.prioritiesLoading = false,
    this.prioritiesError,
    this.selectedSubject,
    this.selectedCategory,
    this.customerTypeId,
    this.fileUiEpoch = 0,
  });

  TicketMasterDataState copyWith({
    List<SubjectEntity>? subjects,
    bool? subjectsLoading,
    Object? subjectsError = _unset,
    List<TicketCategoryEntity>? categories,
    bool? categoriesLoading,
    Object? categoriesError = _unset,
    List<PriorityEntity>? priorities,
    bool? prioritiesLoading,
    Object? prioritiesError = _unset,
    Object? selectedSubject = _unset,
    Object? selectedCategory = _unset,
    Object? customerTypeId = _unset,
    int? fileUiEpoch,
  }) {
    return TicketMasterDataState(
      subjects: subjects ?? this.subjects,
      subjectsLoading: subjectsLoading ?? this.subjectsLoading,
      subjectsError: subjectsError == _unset
          ? this.subjectsError
          : subjectsError as String?,
      categories: categories ?? this.categories,
      categoriesLoading: categoriesLoading ?? this.categoriesLoading,
      categoriesError: categoriesError == _unset
          ? this.categoriesError
          : categoriesError as String?,
      priorities: priorities ?? this.priorities,
      prioritiesLoading: prioritiesLoading ?? this.prioritiesLoading,
      prioritiesError: prioritiesError == _unset
          ? this.prioritiesError
          : prioritiesError as String?,
      selectedSubject: selectedSubject == _unset
          ? this.selectedSubject
          : selectedSubject as SubjectEntity?,
      selectedCategory: selectedCategory == _unset
          ? this.selectedCategory
          : selectedCategory as TicketCategoryEntity?,
      customerTypeId: customerTypeId == _unset
          ? this.customerTypeId
          : customerTypeId as String?,
      fileUiEpoch: fileUiEpoch ?? this.fileUiEpoch,
    );
  }

  @override
  List<Object?> get props => [
    subjects,
    subjectsLoading,
    subjectsError,
    categories,
    categoriesLoading,
    categoriesError,
    priorities,
    prioritiesLoading,
    prioritiesError,
    selectedSubject,
    selectedCategory,
    customerTypeId,
    fileUiEpoch,
  ];
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

  const TicketsLoaded({required this.data, this.isLoadingMore = false});

  TicketsLoaded copyWith({
    TicketsListResponseEntity? data,
    bool? isLoadingMore,
  }) {
    return TicketsLoaded(
      data: data ?? this.data,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
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

  const NoteSubmitted({required this.respoEntity});
}

class OnError extends TicketState {
  final String errorMessage;
  final TicketsListResponseEntity? previousData;

  const OnError({required this.errorMessage, this.previousData});
}
