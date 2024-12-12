import 'package:taste_tube/global_data/watch/video.dart';

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
  final List<Video> videos;

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
    required this.videos,
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
      videos: (json['videos'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList(),
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
      videos: videos,
    );
  }
}
