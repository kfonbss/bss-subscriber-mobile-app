import 'package:kfon_subscriber/features/auth/data/model/verify_otp_model.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/verify_otp_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kfon_subscriber/features/auth/domain/entity/auth_entity.dart';
import 'package:kfon_subscriber/features/auth/domain/params/login_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/reset_password_params.dart';
import 'package:kfon_subscriber/features/auth/domain/params/verify_otp_params.dart';
import 'package:kfon_subscriber/features/auth/domain/repository/auth_repository.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_event.dart';
import 'package:kfon_subscriber/features/auth/presentation/bloc/auth_state.dart';
import 'package:kfon_subscriber/core/util/preference_util.dart';
import 'package:kfon_subscriber/features/profile/domain/entity/profile_entity.dart';
import 'package:kfon_subscriber/l10n/l10n_ext.dart';

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
    on<ResendForgotPasswordOtpRequested>(_onResendForgotPasswordOtpRequested);
    on<VerifyForgotPasswordOtpRequested>(_onVerifyForgotPasswordOtpRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onLoadSelectedTenant(
    LoadSelectedTenant event,
    Emitter<AuthState> emit,
  ) async {
    String tenantName = await PreferenceUtils.getTenantName() ?? '';
    String tenantId = await PreferenceUtils.getTenantId() ?? '';
    emit(LoadSelectedTenantSuccess(tenantId: tenantId, tenantName: tenantName));
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final tenantId = await PreferenceUtils.getTenantId() ?? '';
      final accessToken = await PreferenceUtils.getAccessToken();
      if (tenantId.isEmpty || accessToken == null || accessToken.isEmpty) {
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
          event.rememberMe
              ? PreferenceUtils.saveLoginCredentials(
                event.username,
                event.password,
              )
              : PreferenceUtils.clearLoginCredentials();
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
    // Drives the loader on the logout sheet's Logout button.
    emit(const LogoutLoading());
    try {
      final refreshToken = await PreferenceUtils.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final logoutResult = await authRepository.logout(refreshToken);
        await logoutResult.fold(
          (error) {
            emit(LogoutFailure(errorMessage: error.toString()));
          },
          (_) async {
            await PreferenceUtils.clearAll(true);
            _authEntity = null;
            forgotPasswordUsername = null;
            forgotPasswordToken = null;
            otpRefId = null;
            emit(const LogoutSuccess());
            emit(const Unauthenticated());
          },
        );
      } else {
        await PreferenceUtils.clearAll(true);
        _authEntity = null;
        forgotPasswordUsername = null;
        forgotPasswordToken = null;
        otpRefId = null;
        emit(const LogoutSuccess());
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(LogoutFailure(errorMessage: e.toString()));
    }
  }

  Future<void> _onResendOTP(ResendOTP event, Emitter<AuthState> emit) async {
    try {
      final result = await authRepository.resendOTP(event.loginSessionToken);

      await result.fold(
        (error) async {
          // Was LoginFailure before — OtpVerificationPage doesn't listen for
          // that, so a resend error was silently dropped. It listens for
          // OtpVerificationFailed instead.
          emit(OtpVerificationFailed(errorMessage: error.toString()));
        },
        (authEntity) async {
          _authEntity = authEntity;
          // Deliberately NOT LoginSuccess — see OtpResendSuccess doc comment.
          emit(OtpResendSuccess(user: authEntity));
        },
      );
    } catch (e) {
      emit(OtpVerificationFailed(errorMessage: e.toString()));
    }
  }

  /// Resend for the forgot-password OTP screen. Mirrors
  /// [_onSendForgotPasswordOtpRequested] but emits [ForgotPasswordOtpResent]
  /// instead of [OtpSent] — see that state's doc comment for why.
  Future<void> _onResendForgotPasswordOtpRequested(
    ResendForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      otpRefId = null;
      final result = await authRepository.sendForgotPasswordOtp(event.username);

      result.fold(
        (error) {
          emit(OtpVerificationFailed(errorMessage: error.toString()));
        },
        (otpResponse) {
          forgotPasswordUsername = event.username;
          otpRefId = otpResponse.otpRefId;
          final mobileNumber = otpResponse.mobileNumber ?? '';
          emit(ForgotPasswordOtpResent(mobileNumber: mobileNumber));
        },
      );
    } catch (e) {
      emit(OtpVerificationFailed(errorMessage: e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(
    VerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());

      if (_authEntity == null) {
        emit(
          OtpVerificationFailed(
            errorMessage: appL10n.yourSessionHasExpiredPleaseLogIn,
          ),
        );
        return;
      }

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
    // Guard first: if a prior resend failed, otpRefId can be null. Without
    // this check the null-assertion below throws, gets swallowed by the
    // catch block, and the user sees a raw exception string instead of a
    // clean message.
    if (otpRefId == null || otpRefId!.isEmpty) {
      emit(
        OtpVerificationFailed(
          errorMessage: appL10n.otpSessionExpiredPleaseRequestANew,
        ),
      );
      return;
    }

    try {
      emit(const AuthLoading());

      final params = VerifyOtpParams(otpRefId: otpRefId!, otp: event.otp);

      final result = await authRepository.verifyForgotPasswordOtp(params);

      result.fold(
        (error) {
          emit(OtpVerificationFailed(errorMessage: error.toString()));
        },
        (verifyResponseData) {
          // final allowedRole = verifyResponseData.userRole;
          // if (allowedRole == null || !UserRole.values.contains(allowedRole)) {
          //   emit(
          //     OtpVerificationFailed(
          //       errorMessage: appL10n.youDoNotHaveAccessToThis,
          //     ),
          //   );
          //   return;
          // }
          forgotPasswordToken = verifyResponseData.otpRefId;
          otpRefId = null;
          emit(const ForgotPasswordOtpVerified());
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
    // Guard first: these are only set by a successful forgot-password flow.
    // Asserting them with `!` when null would throw inside the try block
    // and surface as a raw exception message instead of a clean one.
    if (forgotPasswordUsername == null || forgotPasswordUsername!.isEmpty) {
      emit(
        PasswordResetError(
          errorMessage: appL10n.otpSessionExpiredPleaseRequestANew,
        ),
      );
      return;
    }
    if (forgotPasswordToken == null || forgotPasswordToken!.isEmpty) {
      emit(
        PasswordResetError(
          errorMessage: appL10n.verificationExpiredPleaseVerifyTheOtpAgain,
        ),
      );
      return;
    }

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
          // Clear the short-lived forgot-password session state now that
          // it's been consumed.
          forgotPasswordUsername = null;
          forgotPasswordToken = null;
          emit(const PasswordResetSuccess());
        },
      );
    } catch (e) {
      emit(PasswordResetError(errorMessage: e.toString()));
    }
  }
}
