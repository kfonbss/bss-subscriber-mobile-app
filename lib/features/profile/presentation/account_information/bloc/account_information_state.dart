import 'package:equatable/equatable.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/account_information_entity.dart';

abstract class AccountInformationState extends Equatable {
  const AccountInformationState();

  @override
  List<Object?> get props => [];
}

class AccountInformationInitial extends AccountInformationState {
  const AccountInformationInitial();
}

class AccountInformationLoading extends AccountInformationState {
  const AccountInformationLoading();
}

class AccountInformationLoaded extends AccountInformationState {
  final AccountInformationEntity accountInformation;

  const AccountInformationLoaded({required this.accountInformation});

  @override
  List<Object?> get props => [accountInformation];
}

class AccountInformationError extends AccountInformationState {
  final String message;

  const AccountInformationError({required this.message});

  @override
  List<Object?> get props => [message];
}
