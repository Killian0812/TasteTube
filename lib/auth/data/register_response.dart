class RegisterResponse {
  final String userId;

  const RegisterResponse(
    this.userId,
  );

  RegisterResponse.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] as String;
}
