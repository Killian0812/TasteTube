class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String email;
  final String username;
  final String image;
  final String role;
  final String currency;

  const LoginResponse(
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.email,
    this.username,
    this.image,
    this.role,
    this.currency,
  );

  LoginResponse.fromJson(Map<String, dynamic> json, this.refreshToken)
      : accessToken = json['accessToken'] as String,
        userId = json['userId'] as String,
        email = json['email'] as String,
        username = json['username'] as String,
        image = json['image'] as String,
        role = json['role'] as String,
        currency = json['currency'] as String;
}
