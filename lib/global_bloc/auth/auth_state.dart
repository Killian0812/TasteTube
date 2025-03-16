part of 'auth_bloc.dart';

class AuthData {
  final String accessToken;
  final String userId;
  final String email;
  final String username;
  final String image;
  final String role;
  final String currency;

  const AuthData({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.username,
    required this.image,
    required this.role,
    required this.currency,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'],
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
      image: json['image'],
      role: json['role'],
      currency: json['currency'],
    );
  }

  AuthData copyWith({
    String? accessToken,
    String? userId,
    String? email,
    String? username,
    String? image,
    String? role,
    String? currency,
  }) {
    return AuthData(
      accessToken: accessToken ?? this.accessToken,
      userId: userId ?? this.userId,
      email: email ?? this.email,
      username: username ?? this.username,
      image: image ?? this.image,
      role: role ?? this.role,
      currency: currency ?? this.currency,
    );
  }
}

abstract class AuthState {
  final AuthData? data;
  const AuthState({this.data});
}

class Initial extends AuthState {}

class Authenticated extends AuthState {
  final AuthData _data;

  const Authenticated(this._data) : super(data: _data);

  @override
  AuthData get data => _data;
}

class Unauthenticated extends AuthState {}
