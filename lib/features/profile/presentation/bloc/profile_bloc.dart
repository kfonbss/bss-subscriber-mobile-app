import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/profile/domain/repository/profile_repository.dart';
import 'package:kfon_subscriber/features/profile/presentation/bloc/profile_event.dart';
import 'package:kfon_subscriber/features/profile/presentation/bloc/profile_state.dart';

const bool kBypassLoginOtp = true;

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(const ProfileInitial()) {
        on<LogoutRequested>(_onLogoutRequested);
  }


  Future<void> _onLogoutRequested(
      LogoutRequested event,
      Emitter<ProfileState> emit,
      ) async {
    try {
      final refreshToken = await PreferenceUtils.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final logoutResult = await repository.logout(refreshToken);
        await logoutResult.fold(
              (error) {
            emit(LogoutFailure(errorMessage: error.toString()));
          },
              (_) async {
            // await PreferenceUtils.clearAll();
            // otpRefId = null;
            // _authEntity = null;
            // forgotPasswordUsername = null;
            emit(const LogoutSuccess());
            emit(const Unauthenticated());
          },
        );
      } else {
        await PreferenceUtils.clearAll();
        emit(const LogoutSuccess());
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(LogoutFailure(errorMessage: e.toString()));
    }
  }

}
