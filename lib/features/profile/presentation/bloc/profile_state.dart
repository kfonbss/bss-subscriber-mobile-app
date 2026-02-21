import 'package:equatable/equatable.dart';
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class LogoutLoading extends ProfileState {
  const LogoutLoading();
}

class LogoutSuccess extends ProfileState {
  const LogoutSuccess();
}

class LogoutFailure extends ProfileState {
  final String errorMessage;

  const LogoutFailure({required this.errorMessage});

  @override
  List<Object?> get props => [errorMessage];
}

class Unauthenticated extends ProfileState {
  const Unauthenticated();
}