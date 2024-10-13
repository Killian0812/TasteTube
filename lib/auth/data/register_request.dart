class RegisterRequest {
  final String email;
  final String password;

  const RegisterRequest(this.email, this.password);

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class SetRoleRequest {
  final String userId;
  final String role;

  const SetRoleRequest(this.userId, this.role);

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'role': role,
      };
}
