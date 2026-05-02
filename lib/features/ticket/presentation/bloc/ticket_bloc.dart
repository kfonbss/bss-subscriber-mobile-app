import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/ticket/domain/entity/tickets_list_response_entity.dart';
import 'package:kfon_subscriber/features/ticket/domain/params/get_tickets_list_params.dart';
import 'package:kfon_subscriber/features/ticket/domain/repository/ticket_repository.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_event.dart';
import 'package:kfon_subscriber/features/ticket/presentation/bloc/ticket_state.dart';

class TicketBloc extends Bloc<TicketEvent, TicketState> {
  final TicketRepository ticketRepository;
  static const int pageSize = 10;

  /// Last list request (page 0 refresh/load); used so [LoadMoreTickets] keeps the same search.
  GetTicketsListParams _lastTicketsParams = const GetTicketsListParams(
    page: 0,
    size: pageSize,
  );

  /// Cached master data for create-ticket flows; survives concurrent loads.
  TicketMasterDataState _master = const TicketMasterDataState();

  TicketBloc({required this.ticketRepository}) : super(const TicketInitial()) {
    on<LoadSubjects>(_onLoadSubjects);
    on<LoadCategories>(_onLoadCategories);
    on<LoadCustomerTypeId>(_onLoadCustomerTypeId);
    on<LoadPriorities>(_onLoadPriorities);
    on<OnSubmitTicket>(_onSubmitTicket);
    on<LoadTickets>(_onLoadTickets);
    on<LoadMoreTickets>(_onLoadMoreTickets);
    on<RefreshTickets>(_onRefreshTickets);
    on<LoadVisibilityPermissions>(_onLoadVisibilityPermissions);
    on<OnSubjectSelect>(_onSubjectSelect);
    on<OnCategorySelect>(_onCategorySelect);
    on<OnFileSelect>(_onFileSelect);
    on<OnAddNote>(_onAddNote);
  }

  void _emitMaster(Emitter<TicketState> emit) {
    emit(_master);
  }

  void _onSubjectSelect(OnSubjectSelect event, Emitter<TicketState> emit) {
    _master = _master.copyWith(selectedSubject: event.subject);
    _emitMaster(emit);
  }

  void _onCategorySelect(OnCategorySelect event, Emitter<TicketState> emit) {
    _master = _master.copyWith(
      selectedCategory: event.category,
      selectedSubject: null,
      subjects: const [],
      subjectsError: null,
    );
    _emitMaster(emit);
    add(LoadSubjects(categoryId: event.category.id));
  }

  void _onFileSelect(OnFileSelect event, Emitter<TicketState> emit) {
    _master = _master.copyWith(fileUiEpoch: _master.fileUiEpoch + 1);
    _emitMaster(emit);
  }

  Future<void> _onLoadSubjects(
      LoadSubjects event,
      Emitter<TicketState> emit,
      ) async {
    try {
      _master = _master.copyWith(
        subjectsLoading: true,
        subjectsError: null,
      );
      _emitMaster(emit);

      final result = await ticketRepository.getSubjects(
        categoryId: event.categoryId,
      );

      result.fold(
            (error) {
          _master = _master.copyWith(
            subjectsLoading: false,
            subjectsError: error.toString(),
          );
          _emitMaster(emit);
        },
            (subjects) {
          _master = _master.copyWith(
            subjectsLoading: false,
            subjectsError: null,
            subjects: subjects,
          );
          _emitMaster(emit);
        },
      );
    } catch (e) {
      _master = _master.copyWith(
        subjectsLoading: false,
        subjectsError: e.toString(),
      );
      _emitMaster(emit);
    }
  }

  Future<void> _onLoadCategories(
      LoadCategories event,
      Emitter<TicketState> emit,
      ) async {
    try {
      _master = _master.copyWith(
        categoriesLoading: true,
        categoriesError: null,
      );
      _emitMaster(emit);

      final result = await ticketRepository.getCategories();

      result.fold(
            (error) {
          _master = _master.copyWith(
            categoriesLoading: false,
            categoriesError: error.toString(),
          );
          _emitMaster(emit);
        },
            (categories) {
          _master = _master.copyWith(
            categoriesLoading: false,
            categoriesError: null,
            categories: categories,
          );
          _emitMaster(emit);
        },
      );
    } catch (e) {
      _master = _master.copyWith(
        categoriesLoading: false,
        categoriesError: e.toString(),
      );
      _emitMaster(emit);
    }
  }

  Future<void> _onLoadCustomerTypeId(
      LoadCustomerTypeId event,
      Emitter<TicketState> emit,
      ) async {
    try {
      final result = await ticketRepository.getCustomerTypes();

      result.fold(
            (error) {
          // Non-blocking: just log; submit will guard via null check
        },
            (customerTypes) {
          final match = customerTypes
              .where(
                (ct) =>
            ct.code.toUpperCase() == event.code.toUpperCase() &&
                ct.isActive,
          )
              .firstOrNull;

          if (match != null) {
            _master = _master.copyWith(customerTypeId: match.id);
            _emitMaster(emit);
          }
        },
      );
    } catch (_) {
      // Non-blocking: submit will guard via null check
    }
  }

  Future<void> _onLoadPriorities(
      LoadPriorities event,
      Emitter<TicketState> emit,
      ) async {
    try {
      _master = _master.copyWith(
        prioritiesLoading: true,
        prioritiesError: null,
      );
      _emitMaster(emit);

      final result = await ticketRepository.getPriorities();

      result.fold(
            (error) {
          _master = _master.copyWith(
            prioritiesLoading: false,
            prioritiesError: error.toString(),
          );
          _emitMaster(emit);
        },
            (priorities) {
          _master = _master.copyWith(
            prioritiesLoading: false,
            prioritiesError: null,
            priorities: priorities,
          );
          _emitMaster(emit);
        },
      );
    } catch (e) {
      _master = _master.copyWith(
        prioritiesLoading: false,
        prioritiesError: e.toString(),
      );
      _emitMaster(emit);
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
          _emitMaster(emit);
        },
            (respoEntity) {
          emit(TicketSubmitted(respoEntity: respoEntity));
        },
      );
    } catch (e) {
      emit(OnError(errorMessage: e.toString()));
      _emitMaster(emit);
    }
  }

  Future<void> _onLoadTickets(
      LoadTickets event,
      Emitter<TicketState> emit,
      ) async {
    _lastTicketsParams = event.params;

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
      final nextPage = currentState.data.pageInfo.pageNumber + 1;
      final params = GetTicketsListParams(
        page: nextPage,
        size: pageSize,
        search: _lastTicketsParams.search,
        priority: _lastTicketsParams.priority,
        status: _lastTicketsParams.status,
        createdDateFrom: _lastTicketsParams.createdDateFrom,
        createdDateTo: _lastTicketsParams.createdDateTo,
        type: _lastTicketsParams.type,
      );

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

  Future<void> _onAddNote(
      OnAddNote event,
      Emitter<TicketState> emit,
      ) async {
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
    _lastTicketsParams = event.params;

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
