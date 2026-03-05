import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/profile/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileInitial()) {
    on<FetchProfileRequested>(_onFetchProfile);
  }

  Future<void> _onFetchProfile(
    FetchProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());
      final result = await repository.getProfile();
      result.fold(
        (failure) => emit(ProfileError(message: failure.toString())),
        (profile) => emit(ProfileLoaded(profile: profile)),
      );
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }
}
