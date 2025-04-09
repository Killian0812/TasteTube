part of 'auth_bloc.dart';

abstract class AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final AuthData data;
  LoginEvent(this.data);
}

class UpdateCurrencyEvent extends AuthEvent {
  final String currency;
  UpdateCurrencyEvent(this.currency);
}

class LogoutEvent extends AuthEvent {}
