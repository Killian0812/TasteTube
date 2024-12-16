import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPhoneCubit extends Cubit<LoginPhoneState> {
  Timer? _timer;

  LoginPhoneCubit() : super(LoginPhoneState("", false, false));

  void editPhone(String phone) {
    final canSendOtp = phone.length >= 12;
    emit(LoginPhoneState(phone, canSendOtp, false));
  }

  void sendOtp() {
    if (!state.canSendOtp || state.isLoading) return;

    emit(LoginPhoneState(state.phone, true, true));
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 10), () {
      emit(LoginPhoneState(state.phone, false, false));
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

class LoginPhoneState {
  final String phone;
  final bool canSendOtp;
  final bool isLoading;

  LoginPhoneState(this.phone, this.canSendOtp, this.isLoading);

  LoginPhoneState copyWith({
    String? phone,
    bool? canSendOtp,
    bool? isLoading,
  }) {
    return LoginPhoneState(
      phone ?? this.phone,
      canSendOtp ?? this.canSendOtp,
      isLoading ?? this.isLoading,
    );
  }
}
