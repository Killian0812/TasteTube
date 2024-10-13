class RegisterResponse {
  final String message;

  const RegisterResponse(
    this.message,
  );

  RegisterResponse.fromJson(Map<String, dynamic> json)
      : message = json['message'] as String;
}
