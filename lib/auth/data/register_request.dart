class RegisterRequest {
  final String email;
  final String password;

  const RegisterRequest(this.email, this.password);

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}