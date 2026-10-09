import 'package:kfon_subscriber/features/future_recharge/domain/entity/future_recharges_list_response_entity.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/params/get_future_recharges_list_params.dart';
import 'package:kfon_subscriber/features/future_recharge/domain/repository/future_recharge_repository.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/bloc/future_recharge_event.dart';
import 'package:kfon_subscriber/features/future_recharge/presentation/bloc/future_recharge_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FutureRechargeBloc
    extends Bloc<FutureRechargeEvent, FutureRechargeState> {
  final FutureRechargeRepository rechargeRepository;
  static const int pageSize = 15;

  GetFutureRechargesListParams _lastRechargesParams =
      const GetFutureRechargesListParams(
        period: 'TODAY',
        page: 0,
        size: pageSize,
      );

  FutureRechargeBloc({required this.rechargeRepository})
    : super(const RechargeInitial()) {
    on<LoadRecharges>(_onLoadRecharges);
    on<RefreshRecharges>(_onRefreshRecharges);
    on<LoadMoreRecharges>(_onLoadMoreRecharges);
    on<ApplyRechargeFilter>(_onApplyFilter);
    on<ClearRechargeFilter>(_onClearFilter);
    on<ChangePeriodTab>(_onChangePeriodTab);
  }

  // ── Load ──────────────────────────────────────────────────────────────────
  Future<void> _onLoadRecharges(
    LoadRecharges event,
    Emitter<FutureRechargeState> emit,
  ) async {
    _lastRechargesParams = event.params;

    final currentState = state;
    FutureRechargesListResponseEntity? previousData;
    if (currentState is RechargeLoaded) previousData = currentState.data;
    if (currentState is RechargeError) previousData = currentState.previousData;

    emit(RechargeLoading(previousData: previousData));

    try {
      final result = await rechargeRepository.getRechargesList(
        event.params,
        event.isFutureRecharge,
      );
      result.fold(
        (error) => emit(
          RechargeError(
            errorMessage: error.toString(),
            previousData: previousData,
          ),
        ),
        (data) => emit(RechargeLoaded(data: data)),
      );
    } catch (e) {
      emit(
        RechargeError(errorMessage: e.toString(), previousData: previousData),
      );
    }
  }

  // ── Refresh ───────────────────────────────────────────────────────────────
  Future<void> _onRefreshRecharges(
    RefreshRecharges event,
    Emitter<FutureRechargeState> emit,
  ) async {
    _lastRechargesParams = event.params;

    final currentState = state;
    FutureRechargesListResponseEntity? currentData;
    if (currentState is RechargeLoaded) {
      currentData = currentState.data;
      emit(RechargeRefreshing(currentData: currentData));
    }

    try {
      final result = await rechargeRepository.getRechargesList(
        event.params,
        event.isFutureRecharge,
      );
      result.fold((error) {
        if (currentData != null) {
          emit(RechargeLoaded(data: currentData));
        } else {
          emit(RechargeError(errorMessage: error.toString()));
        }
      }, (data) => emit(RechargeLoaded(data: data)));
    } catch (e) {
      if (currentData != null) {
        emit(RechargeLoaded(data: currentData));
      } else {
        emit(RechargeError(errorMessage: e.toString()));
      }
    }
  }

  // ── Load more ─────────────────────────────────────────────────────────────
  Future<void> _onLoadMoreRecharges(
    LoadMoreRecharges event,
    Emitter<FutureRechargeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! RechargeLoaded) return;

    if (currentState.data.pageInfo.isLast ||
        currentState.data.pageInfo.isEmpty ||
        currentState.isLoadingMore)
      return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.data.pageInfo.pageNumber + 1;
      final params = _lastRechargesParams.copyWith(
        page: nextPage,
        size: pageSize,
      );
      final result = await rechargeRepository.getRechargesList(
        params,
        event.isFutureRecharge,
      );
      result.fold(
        (error) => emit(currentState.copyWith(isLoadingMore: false)),
        (response) {
          final allGroups = [...currentState.data.groups, ...response.groups];
          emit(
            RechargeLoaded(
              data: FutureRechargesListResponseEntity(
                summary: response.summary,
                groups: allGroups,
                pageInfo: response.pageInfo,
              ),
              isLoadingMore: false,
              rechargeType: currentState.rechargeType,
              selectedMonth: currentState.selectedMonth,
              selectedYear: currentState.selectedYear,
              periodIndex: currentState.periodIndex,
            ),
          );
        },
      );
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  // ── Apply filter ──────────────────────────────────────────────────────────
  Future<void> _onApplyFilter(
    ApplyRechargeFilter event,
    Emitter<FutureRechargeState> emit,
  ) async {
    _lastRechargesParams = _lastRechargesParams.copyWith(
      page: 0,
      rechargeType: event.rechargeType,
      month: event.selectedMonth?.month,
      year: event.selectedMonth?.year ?? event.selectedYear,
    );

    final loaded = state is RechargeLoaded ? state as RechargeLoaded : null;
    final previousData = loaded?.data;

    // 👇 pass periodIndex so tab doesn't flash
    emit(
      RechargeLoading(
        previousData: previousData,
        isTabChange: true,
        periodIndex: loaded?.periodIndex ?? 0,
      ),
    );

    final result = await rechargeRepository.getRechargesList(
      _lastRechargesParams,
      event.isFutureRecharge,
    );
    result.fold(
      (error) => emit(
        RechargeError(errorMessage: error.message, previousData: previousData),
      ),
      (data) => emit(
        RechargeLoaded(
          data: data,
          rechargeType: event.rechargeType,
          selectedMonth: event.selectedMonth,
          selectedYear: event.selectedYear,
          periodIndex: loaded?.periodIndex ?? 0,
        ),
      ),
    );
  }

  // ── Clear filter ──────────────────────────────────────────────────────────
  Future<void> _onClearFilter(
    ClearRechargeFilter event,
    Emitter<FutureRechargeState> emit,
  ) async {
    _lastRechargesParams = _lastRechargesParams.copyWith(
      page: 0,
      rechargeType: RechargeTypeFilter.all,
      month: null,
      year: null,
    );

    final loaded = state is RechargeLoaded ? state as RechargeLoaded : null;
    final previousData = loaded?.data;

    // 👇 pass periodIndex so tab doesn't flash
    emit(
      RechargeLoading(
        previousData: previousData,
        isTabChange: true,
        periodIndex: loaded?.periodIndex ?? 0,
      ),
    );

    final result = await rechargeRepository.getRechargesList(
      _lastRechargesParams,
      event.isFutureRecharge,
    );
    result.fold(
      (error) => emit(
        RechargeError(errorMessage: error.message, previousData: previousData),
      ),
      (data) => emit(
        RechargeLoaded(data: data, periodIndex: loaded?.periodIndex ?? 0),
      ),
    );
  }

  // ── Change period tab ─────────────────────────────────────────────────────
  Future<void> _onChangePeriodTab(
    ChangePeriodTab event,
    Emitter<FutureRechargeState> emit,
  ) async {
    final period = switch (event.index) {
      0 => 'TODAY',
      1 => 'THIS_WEEK',
      2 => 'THIS_MONTH',
      _ => 'TODAY',
    };

    final loaded = state is RechargeLoaded ? state as RechargeLoaded : null;
    final previousData = loaded?.data;

    _lastRechargesParams = _lastRechargesParams.copyWith(
      period: period,
      page: 0,
    );

    // 👇 pass event.index immediately — tab highlights at once
    emit(
      RechargeLoading(
        previousData: previousData,
        isTabChange: true,
        periodIndex: event.index,
      ),
    );

    final result = await rechargeRepository.getRechargesList(
      _lastRechargesParams,
      event.isFutureRecharge,
    );
    result.fold(
      (error) => emit(
        RechargeError(errorMessage: error.message, previousData: previousData),
      ),
      (data) => emit(
        RechargeLoaded(
          data: data,
          rechargeType: loaded?.rechargeType ?? RechargeTypeFilter.all,
          selectedMonth: loaded?.selectedMonth,
          selectedYear: loaded?.selectedYear,
          periodIndex: event.index,
        ),
      ),
    );
  }
}
