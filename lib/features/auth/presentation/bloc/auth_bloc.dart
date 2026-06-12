import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/auth/data/model/verify_otp_model.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/verify_otp_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/params/login_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/reset_password_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/verify_otp_params.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/auth_repository.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  String? loginSessionToken;
  String? forgotPasswordUsername;
  String? forgotPasswordToken;
  AuthEntity? _authEntity;
  String? otpRefId;

  AuthBloc({required this.authRepository}) : super(const AuthInitial()) {
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<LoadSelectedTenant>(_onLoadSelectedTenant);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ResendOTP>(_onResendOTP);
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
      final tenantId = await PreferenceUtils.getTenantId() ?? '';
      if (tenantId.isEmpty) {
        emit(const Unauthenticated());
      } else {
        final userProfile = await authRepository.getUserProfile();
        userProfile.fold(
          (failure) {
            emit(const Unauthenticated());
          },
          (profileEntity) {
            emit(const Authenticated());
          },
        );
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
        tenantId: event.tenantId,
      );

      final result = await authRepository.login(loginParams);

      await result.fold(
        (error) async {
          emit(LoginFailure(errorMessage: error.toString()));
        },
        (authEntity) async {
          _authEntity = authEntity;
          emit(LoginSuccess(user: authEntity));
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
            _authEntity = null;
            forgotPasswordUsername = null;
            emit(const LogoutSuccess());
            emit(const Unauthenticated());
          },
        );
      } else {
        await PreferenceUtils.clearAll();
        _authEntity = null;
        forgotPasswordUsername = null;
        emit(const LogoutSuccess());
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(LogoutFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onLoadSelectedTenant(
      LoadSelectedTenant event,
      Emitter<AuthState> emit,
      ) async {
    String tenantName = await PreferenceUtils.getTenantName() ?? '';
    String tenantId = await PreferenceUtils.getTenantId() ?? '';
    emit(LoadSelectedTenantSuccess(tenantId: tenantId, tenantName: tenantName));
  }
  Future<void> _onResendOTP(ResendOTP event, Emitter<AuthState> emit) async {
    try {
      final result = await authRepository.resendOTP(event.loginSessionToken);

      await result.fold(
        (error) async {
          emit(LoginFailure(errorMessage: error.toString()));
        },
        (authEntity) async {
          _authEntity = authEntity;
          emit(LoginSuccess(user: authEntity));
        },
      );
    } catch (e) {
      emit(LogoutFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      final params = VerifyOtpParams(
        otpRefId: _authEntity!.otpRefId,
        otp: event.otp,
        loginSessionToken: _authEntity!.loginSessionToken,
      );

      final result = await authRepository.verifyOtp(params);
      if (result.isLeft()) {
        final error = result.fold((l) => l, (r) => null)!;
        emit(OtpVerificationFailed(errorMessage: error.message));
      } else {
        final response = result.fold((l) => null, (r) => r)!;

        if (response.userRole == null || response.userRole != UserRole.sub) {
          emit(
            const OtpVerificationFailed(
              errorMessage:
                  'You do not have access to this app. Please contact support.',
            ),
          );
          return;
        }
        await PreferenceUtils.saveAllTokens(
          accessToken: response.token,
          refreshToken: response.refreshToken,
          expiresIn: response.expiresIn,
        );
        _authEntity = null;
        otpRefId = null;
        emit(const OtpVerified());
      }
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
          emit(const ForgotPasswordOtpVerified());
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
