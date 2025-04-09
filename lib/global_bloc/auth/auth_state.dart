part of 'auth_bloc.dart';

class AuthData {
  final String streamToken;
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String username;
  final String image;
  final String role;
  final String currency;

  const AuthData({
    required this.streamToken,
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.email,
    required this.username,
    required this.image,
    required this.role,
    required this.currency,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      streamToken: json['streamToken'],
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
      image: json['image'],
      role: json['role'],
      currency: json['currency'],
    );
  }

  AuthData copyWith({
    String? streamToken,
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? email,
    String? username,
    String? image,
    String? role,
    String? currency,
  }) {
    return AuthData(
      streamToken: streamToken ?? this.streamToken,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
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
