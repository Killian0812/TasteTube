class LoginResponse {
  final String accessToken;
  final String userId;
  final String email;
  final String username;
  final String image;

  const LoginResponse(
    this.accessToken,
    this.userId,
    this.email,
    this.username,
    this.image,
  );

  LoginResponse.fromJson(Map<String, dynamic> json)
      : accessToken = json['accessToken'] as String,
        userId = json['userId'] as String,
        email = json['email'] as String,
        username = json['username'] as String,
        image = json['image'] as String;
}