import 'package:equatable/equatable.dart';

abstract class AccountInformationEvent extends Equatable {
  const AccountInformationEvent();

  @override
  List<Object?> get props => [];
}

class FetchAccountInformationRequested extends AccountInformationEvent {
  const FetchAccountInformationRequested();
}
