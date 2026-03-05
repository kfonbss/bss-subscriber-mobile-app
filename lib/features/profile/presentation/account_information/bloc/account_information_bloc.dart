import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/account_information/bloc/account_information_state.dart';

class AccountInformationBloc
    extends Bloc<AccountInformationEvent, AccountInformationState> {
  final ProfileRepository repository;

  AccountInformationBloc({required this.repository})
    : super(const AccountInformationInitial()) {
    on<FetchAccountInformationRequested>(_onFetchAccountInformation);
  }

  Future<void> _onFetchAccountInformation(
    FetchAccountInformationRequested event,
    Emitter<AccountInformationState> emit,
  ) async {
    try {
      emit(const AccountInformationLoading());
      final result = await repository.getAccountInformation();
      result.fold(
        (failure) => emit(AccountInformationError(message: failure.toString())),
        (accountInfo) =>
            emit(AccountInformationLoaded(accountInformation: accountInfo)),
      );
    } catch (e) {
      emit(AccountInformationError(message: e.toString()));
    }
  }
}
