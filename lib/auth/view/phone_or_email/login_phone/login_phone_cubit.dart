import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import 'package:taste_tube/auth/data/phone_otp_request.dart';
import 'package:taste_tube/auth/domain/auth_repo.dart';
import 'package:taste_tube/core/injection.dart';
import 'package:taste_tube/global_bloc/auth/auth_bloc.dart';

class LoginPhoneCubit extends Cubit<LoginPhoneState> {
  final AuthRepository repository;
  final Logger logger;
  Timer? _cooldownTimer;

  LoginPhoneCubit()
      : repository = getIt<AuthRepository>(),
        logger = getIt<Logger>(),
        super(IdleState(phone: ""));

  void editPhone(String phone) {
    if (state is IdleState || state is ErrorState || state is OtpSentState) {
      emit(IdleState(phone: phone));
    }
  }

  Future<void> sendOtp() async {
    if (!state.canSendOtp) return;

    emit(SendingOtpState(phone: state.phone));

    try {
      final request = PhoneOtpRequest(state.phone);
      final result = await repository.otpRequest(request);

      result.fold(
        (error) {
          logger.e('OTP request failed: ${error.message}');
          emit(ErrorState(
            phone: state.phone,
            errorMessage: error.message ?? 'Error sending OTP',
            activatedAt: null,
          ));
        },
        (response) {
          final activatedAt = response.activatedAt;
          emit(OtpSentState(
            phone: state.phone,
            activatedAt: activatedAt,
            cooldownSeconds: 30,
          ));
          _startCooldownTimer();
        },
      );
    } catch (e) {
      logger.e('Unexpected error sending OTP: $e');
      emit(ErrorState(
        phone: state.phone,
        errorMessage: 'Unexpected error occurred',
        activatedAt: null,
      ));
    }
  }

  Future<void> verifyOtp(String otp) async {
    if (otp.isEmpty || state is VerifyingOtpState || state is SendingOtpState) {
      return;
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      emit(ErrorState(
        phone: state.phone,
        errorMessage: 'OTP must be a 6-digit number',
        activatedAt:
            state is OtpSentState ? (state as OtpSentState).activatedAt : null,
      ));
      return;
    }

    emit(VerifyingOtpState(phone: state.phone, otp: otp));

    try {
      final request = ContinueWithOtpRequest(state.phone, otp);
      final result = await repository.continueWithOtp(request);

      result.fold(
        (error) {
          logger.e('OTP verification failed: ${error.message}');
          emit(ErrorState(
            phone: state.phone,
            errorMessage: error.message ?? 'Error verifying OTP',
            activatedAt: state is OtpSentState
                ? (state as OtpSentState).activatedAt
                : null,
          ));
        },
        (authData) {
          logger.i('OTP verification successful for ${state.phone}');
          getIt<AuthBloc>().add(LoginEvent(authData));
          emit(OtpVerifiedState(phone: state.phone, authData: authData));
          _cooldownTimer?.cancel();
        },
      );
    } catch (e) {
      logger.e('Unexpected error verifying OTP: $e');
      emit(ErrorState(
        phone: state.phone,
        errorMessage: 'Unexpected error occurred',
        activatedAt:
            state is OtpSentState ? (state as OtpSentState).activatedAt : null,
      ));
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state is OtpSentState) {
        final currentState = state as OtpSentState;
        final remainingSeconds = currentState.cooldownSeconds - 1;
        if (remainingSeconds <= 0) {
          timer.cancel();
          emit(IdleState(phone: currentState.phone));
        } else {
          emit(OtpSentState(
            phone: currentState.phone,
            activatedAt: currentState.activatedAt,
            cooldownSeconds: remainingSeconds,
          ));
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  Future<void> close() {
    _cooldownTimer?.cancel();
    return super.close();
  }
}

sealed class LoginPhoneState {
  final String phone;

  LoginPhoneState({required this.phone});

  bool get canSendOtp => phone.length >= 9 && _isCooldownExpired;

  bool get _isCooldownExpired {
    final activatedAt = this is OtpSentState
        ? (this as OtpSentState).activatedAt
        : this is ErrorState
            ? (this as ErrorState).activatedAt
            : null;
    if (activatedAt == null) return true;
    final elapsed = DateTime.now().difference(activatedAt);
    return elapsed.inSeconds >= 30;
  }
}

class IdleState extends LoginPhoneState {
  IdleState({required super.phone});
}

class SendingOtpState extends LoginPhoneState {
  SendingOtpState({required super.phone});

  @override
  bool get canSendOtp => false;
}

class OtpSentState extends LoginPhoneState {
  final DateTime? activatedAt;
  final int cooldownSeconds;

  OtpSentState({
    required super.phone,
    required this.activatedAt,
    required this.cooldownSeconds,
  });
}

class VerifyingOtpState extends LoginPhoneState {
  final String otp;

  VerifyingOtpState({required super.phone, required this.otp});

  @override
  bool get canSendOtp => false;
}

class OtpVerifiedState extends LoginPhoneState {
  final AuthData authData;

  OtpVerifiedState({required super.phone, required this.authData});

  @override
  bool get canSendOtp => false;
}

class ErrorState extends LoginPhoneState {
  final String errorMessage;
  final DateTime? activatedAt;

  ErrorState({
    required super.phone,
    required this.errorMessage,
    this.activatedAt,
  });
}
