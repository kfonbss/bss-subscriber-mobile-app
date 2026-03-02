import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/params/login_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/reset_password_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/verify_otp_params.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/auth_repository.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';

/// Set to true to skip OTP send/verify APIs after login (temporary bypass).
const bool kBypassLoginOtp = false;

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  String? otpRefId;
  String? forgotPasswordUsername;
  String? forgotPasswordToken;
  AuthEntity? _authEntity;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<SendForgotPasswordOtpRequested>(_onSendForgotPasswordOtpRequested);
    on<VerifyForgotPasswordOtpRequested>(_onVerifyForgotPasswordOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final bool isLoggedIn = await authRepository.isLoggedIn();
      if (isLoggedIn) {
        emit(const Authenticated());
       // authRepository.getUserProfile();
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final loginParams = LoginParams(
        userName: event.username,
        password: event.password,
      );

      final result = await authRepository.login(loginParams);

      await result.fold(
        (error) async {
          emit(LoginFailure(errorMessage: error.toString()));
        },
        (authEntity) async {
          otpRefId = null;

          if (kBypassLoginOtp) {
            // Temporary bypass: skip OTP send/verify, save tokens and go to main
            PreferenceUtils.saveAllTokens(
              accessToken: authEntity.token,
              refreshToken: authEntity.refreshToken,
              expiresIn: authEntity.expiresIn,
            );
            _authEntity = authEntity;
            emit(LoginSuccess(user: authEntity));
            return;
          }

          // Send OTP after successful login
          final otpResult = await authRepository.sendOtp(
            authEntity.mobileNumber,
          );

          otpResult.fold(
            (otpError) {
              emit(LoginFailure(errorMessage: otpError.toString()));
            },
            (otpResponse) {
              otpRefId = otpResponse.otpRefId;
              _authEntity = authEntity;
              emit(LoginSuccess(user: authEntity));
            },
          );
        },
      );
    } catch (e) {
      emit(LoginFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final refreshToken = await PreferenceUtils.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final logoutResult = await authRepository.logout(refreshToken);
        await logoutResult.fold(
          (error) {
            emit(LogoutFailure(errorMessage: error.toString()));
          },
          (_) async {
            await PreferenceUtils.clearAll();
            otpRefId = null;
            _authEntity = null;
            forgotPasswordUsername = null;
            emit(const LogoutSuccess());
            emit(const Unauthenticated());
          },
        );
      } else {
        await PreferenceUtils.clearAll();
        otpRefId = null;
        _authEntity = null;
        forgotPasswordUsername = null;
        emit(const LogoutSuccess());
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(LogoutFailure(errorMessage: e.toString()));
    }
  }

  /// Handle login confirm send OTP request
  Future<void> _onSendOtpRequested(
    SendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      otpRefId = null;
      final result = await authRepository.sendOtp(event.mobileNumber);

      result.fold(
        (error) {
          emit(OtpSendError(errorMessage: error.toString()));
        },
        (otpResponse) {
          otpRefId = otpResponse.otpRefId;
          emit(OtpSent(mobileNumber: event.mobileNumber));
        },
      );
    } catch (e) {
      emit(OtpSendError(errorMessage: e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final params = VerifyOtpParams(otpRefId: otpRefId!, otp: event.otp);

      final result = await authRepository.verifyOtp(params);

      result.fold(
        (error) {
          emit(OtpVerificationFailed(errorMessage: error.toString()));
        },
        (_) {
          // Save token to storage after successful OTP verification
          if (_authEntity != null) {
            PreferenceUtils.saveAllTokens(
              accessToken: _authEntity!.token,
              refreshToken: _authEntity!.refreshToken,
              expiresIn: _authEntity!.expiresIn,
            );
          }
          emit(const OtpVerified());
          otpRefId = null;
        },
      );
    } catch (e) {
      emit(OtpVerificationFailed(errorMessage: e.toString()));
    }
  }

  Future<void> _onSendForgotPasswordOtpRequested(
    SendForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      otpRefId = null;
      final result = await authRepository.sendForgotPasswordOtp(event.username);

      result.fold(
        (error) {
          emit(OtpSendError(errorMessage: error.toString()));
        },
        (otpResponse) {
          forgotPasswordUsername = event.username;
          otpRefId = otpResponse.otpRefId;
          String mobileNumber = otpResponse.mobileNumber ?? '';
          emit(OtpSent(mobileNumber: mobileNumber));
        },
      );
    } catch (e) {
      emit(OtpSendError(errorMessage: e.toString()));
    }
  }

  Future<void> _onVerifyForgotPasswordOtpRequested(
    VerifyForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final params = VerifyOtpParams(otpRefId: otpRefId!, otp: event.otp);

      final result = await authRepository.verifyForgotPasswordOtp(params);

      result.fold(
        (error) {
          emit(OtpVerificationFailed(errorMessage: error.toString()));
        },
        (verifyResponseData) {
          forgotPasswordToken = verifyResponseData['token'];
          emit(const OtpVerified());
          otpRefId = null;
        },
      );
    } catch (e) {
      emit(OtpVerificationFailed(errorMessage: e.toString()));
    }
  }

  Future<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final params = ResetPasswordParams(
        username: forgotPasswordUsername!,
        newPassword: event.newPassword.trim(),
        confirmPassword: event.newPassword.trim(),
        token: forgotPasswordToken!,
      );

      final result = await authRepository.resetForgotPassword(params);

      result.fold(
        (error) {
          emit(PasswordResetError(errorMessage: error.toString()));
        },
        (_) {
          emit(const PasswordResetSuccess());
        },
      );
    } catch (e) {
      emit(PasswordResetError(errorMessage: e.toString()));
    }
  }
}
