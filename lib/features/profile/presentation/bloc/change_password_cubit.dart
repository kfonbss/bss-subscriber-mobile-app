import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/profile/domain/params/change_password_params.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object?> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

class ChangePasswordFailure extends ChangePasswordState {
  final String message;

  const ChangePasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Security settings → change BSS portal password.
class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({required this.repository})
    : super(const ChangePasswordInitial());

  final ProfileRepository repository;

  Future<void> changePortalPassword(ChangePasswordParams params) async {
    if (state is ChangePasswordLoading) return;
    emit(const ChangePasswordLoading());
    final result = await repository.changePortalPassword(params);
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => ChangePasswordFailure(failure.message),
        (_) => const ChangePasswordSuccess(),
      ),
    );
  }
}
