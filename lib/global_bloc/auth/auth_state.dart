part of 'auth_bloc.dart';

class AuthData {
  final String accessToken;
  final String userId;
  final String email;
  final String username;
  final String image;
  final String role;

  const AuthData({
    required this.accessToken,
    required this.userId,
    required this.email,
    required this.username,
    required this.image,
    required this.role,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      accessToken: json['accessToken'],
      userId: json['userId'],
      email: json['email'],
      username: json['username'],
      image: json['image'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'userId': userId,
        'email': email,
        'username': username,
        'image': image,
        'role': role,
      };
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
