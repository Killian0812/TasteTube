import 'package:taste_tube/feature/watch/data/video.dart';

class User {
  final String id;
  final String? phone;
  final String? email;
  final String username;
  final String? filename;
  final String? image;
  final String? bio;
  final int? followers;
  final int? followings;
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
    this.followers,
    this.followings,
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
      followers: json['followers'] as int?,
      followings: json['followings'] as int?,
      role: json['role'] as String?,
      videos: (json['videos'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList(),
    );
  }
}
