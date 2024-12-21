class UserBasic {
  final String id;
  final String? phone;
  final String? email;
  final String username;
  final String image;

  UserBasic({
    required this.id,
    required this.phone,
    required this.email,
    required this.username,
    required this.image,
  });

  factory UserBasic.fromJson(Map<String, dynamic> json) {
    return UserBasic(
      id: json['_id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String,
      image: json['image'] as String,
    );
  }
}
