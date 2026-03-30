import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';

import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository ticketRepository;
  static const int pageSize = 10;

  TicketBloc({required this.ticketRepository}) : super(const TicketInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<LoadPriorities>(_onLoadPriorities);
    on<OnSubmitTicket>(_onSubmitTicket);
    on<LoadTickets>(_onLoadTickets);
    on<LoadMoreTickets>(_onLoadMoreTickets);
    on<RefreshTickets>(_onRefreshTickets);
    on<LoadVisibilityPermissions>(_onLoadVisibilityPermissions);
    on<OnSubjectSelect>(
      (event, emit) => emit(SubjectSelected(subject: event.subject)),
    );
    on<OnFileSelect>((event, emit) => emit(FileSelected()));
    on<OnAddNote>(_onAddNote);
  }

  Future<void> _onLoadSubjects(
    LoadSubjects event,
    Emitter<TicketState> emit,
  ) async {
    try {
      final result = await ticketRepository.getSubjects();

      result.fold(
        (error) {
          emit(OnError(errorMessage: error.toString()));
        },
        (subjects) {
          emit(SubjectLoaded(subjects: subjects));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadPriorities(
    LoadPriorities event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(const PriorityLoading());
      final result = await ticketRepository.getPriorities();

      result.fold(
        (error) {
          emit(OnError(errorMessage: error.toString()));
        },
        (priorities) {
          emit(PriorityLoaded(priorities: priorities));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadVisibilityPermissions(
    LoadVisibilityPermissions event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(const VisibilityLoading());
      final result = await ticketRepository.getVisibilityPermissions();

      result.fold(
        (error) {
          emit(OnError(errorMessage: error.toString()));
        },
        (visibilities) {
          emit(VisibilityLoaded(visibilities: visibilities));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString()));
    }
  }

  Future<void> _onSubmitTicket(
    OnSubmitTicket event,
    Emitter<TicketState> emit,
  ) async {
    try {
      emit(const TicketSubmitting());
      final result = await ticketRepository.submitTicket(event.params);

      result.fold(
        (error) {
          emit(OnError(errorMessage: error.toString()));
        },
        (respoEntity) {
          emit(TicketSubmitted(respoEntity: respoEntity));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadTickets(
    LoadTickets event,
    Emitter<TicketState> emit,
  ) async {
    final currentState = state;
    TicketsListResponseEntity? previousData;

    if (currentState is TicketsLoaded) {
      previousData = currentState.data;
    } else if (currentState is OnError) {
      previousData = currentState.previousData;
    }

    emit(TicketsLoading(previousData: previousData));

    try {
      final result = await ticketRepository.getTickets(event.params);

      result.fold(
        (error) {
          emit(
            OnError(errorMessage: error.toString(), previousData: previousData),
          );
        },
        (response) {
          emit(TicketsLoaded(data: response));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString(), previousData: previousData));
    }
  }

  Future<void> _onLoadMoreTickets(
    LoadMoreTickets event,
    Emitter<TicketState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TicketsLoaded) return;

    if (currentState.data.pageInfo.isLast ||
        currentState.isLoadingMore ||
        currentState.data.pageInfo.isEmpty) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final params = event.params;

      final result = await ticketRepository.getTickets(params);

      result.fold(
        (error) {
          emit(currentState.copyWith(isLoadingMore: false));
        },
        (response) {
          final allTickets = [
            ...currentState.data.tickets,
            ...response.tickets,
          ];

          emit(
            TicketsLoaded(
              data: TicketsListResponseEntity(
                pageInfo: response.pageInfo,
                tickets: allTickets,
              ),
              isLoadingMore: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onAddNote(OnAddNote event, Emitter<TicketState> emit) async {
    try {
      emit(const NoteSubmitting());
      final result = await ticketRepository.addNote(event.params);

      result.fold(
        (error) {
          emit(OnError(errorMessage: error.toString()));
        },
        (respoEntity) {
          emit(NoteSubmitted(respoEntity: respoEntity));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString()));
    }
  }

  Future<void> _onRefreshTickets(
    RefreshTickets event,
    Emitter<TicketState> emit,
  ) async {
    final currentState = state;
    TicketsListResponseEntity? currentData;

    if (currentState is TicketsLoaded) {
      currentData = currentState.data;
    }

    if (currentData != null) {
      emit(TicketsRefreshing(currentData: currentData));
    }

    try {
      final result = await ticketRepository.getTickets(event.params);

      result.fold(
        (error) {
          if (currentData != null) {
            emit(TicketsLoaded(data: currentData));
          } else {
            emit(OnError(errorMessage: error.toString()));
          }
        },
        (response) {
          emit(TicketsLoaded(data: response));
        },
      );
    } catch (e) {
      if (currentData != null) {
        emit(TicketsLoaded(data: currentData));
      } else {
        emit(OnError(errorMessage: e.toString()));
      }
    }
  }
}
