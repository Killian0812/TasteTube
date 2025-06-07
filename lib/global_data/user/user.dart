class User {
  final String id;
  final String? phone;
  final String? email;
  final String username;
  final String? filename;
  final String? image;
  final String? bio;
  final List<String> followers;
  final List<String> followings;
  final String? role;
  final String status;

  User({
    required this.id,
    required this.phone,
    required this.email,
    required this.username,
    required this.filename,
    required this.image,
    required this.bio,
    required this.followers,
    required this.followings,
    this.role,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String,
      filename: json['filename'] as String?,
      image: json['image'] as String?,
      bio: json['bio'] as String?,
      followers: (json['followers'] as List<dynamic>)
          .map((followerId) => followerId as String)
          .toList(),
      followings: (json['followings'] as List<dynamic>)
          .map((followerId) => followerId as String)
          .toList(),
      role: json['role'] as String?,
      status: (json['status'] as String?) ?? "ACTIVE",
    );
  }

  User copyWith({
    final List<String>? followers,
  }) {
    return User(
      id: id,
      phone: phone,
      email: email,
      username: username,
      filename: filename,
      image: image,
      bio: bio,
      followers: followers ?? this.followers,
      followings: followings,
      role: role,
      status: status,
    );
  }
}

class PaginatedUserResponse {
  final List<User> users;
  final int totalDocs;
  final int limit;
  final bool hasPrevPage;
  final bool hasNextPage;
  final int page;
  final int totalPages;
  final int? prevPage;
  final int? nextPage;

  PaginatedUserResponse({
    required this.users,
    required this.totalDocs,
    required this.limit,
    required this.hasPrevPage,
    required this.hasNextPage,
    required this.page,
    required this.totalPages,
    this.prevPage,
    this.nextPage,
  });

  factory PaginatedUserResponse.fromJson(Map<String, dynamic> json) {
    return PaginatedUserResponse(
      users: (json['users'] as List<dynamic>)
          .map((userJson) => User.fromJson(userJson as Map<String, dynamic>))
          .toList(),
      totalDocs: json['totalDocs'] as int,
      limit: json['limit'] as int,
      hasPrevPage: json['hasPrevPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      prevPage: json['prevPage'] as int?,
      nextPage: json['nextPage'] as int?,
    );
  }
}
