part of 'bloc.dart';

abstract class AuthEvent {}

class CheckAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final AuthData data;
  LoginEvent(this.data);
}

class LogoutEvent extends AuthEvent {}
