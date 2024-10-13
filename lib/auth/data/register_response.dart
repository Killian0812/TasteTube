class RegisterResponse {
  final String userId;

  const RegisterResponse(
    this.userId,
  );

  RegisterResponse.fromJson(Map<String, dynamic> json)
      : userId = json['userId'] as String;
}

class SetRoleResponse {
  final String message;

  const SetRoleResponse(
    this.message,
  );

  SetRoleResponse.fromJson(Map<String, dynamic> json)
      : message = json['message'] as String;
}
