import 'package:taste_tube/feature/video.dart';

class User {
  final String? phone;
  final String? email;
  final String username;
  final String? filename;
  final String? image;
  final int? followers;
  final int? followings;
  final List<Video> videos;
  final List<Video> likedVideos;

  User({
    required this.phone,
    required this.email,
    required this.username,
    required this.filename,
    required this.image,
    this.followers,
    this.followings,
    required this.videos,
    required this.likedVideos,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      username: json['username'] as String,
      filename: json['filename'] as String?,
      image: json['image'] as String?,
      followers: json['followers'] as int?,
      followings: json['followings'] as int?,
      videos: (json['videos'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList(),
      likedVideos: (json['likedVideos'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'email': email,
      'username': username,
      'filename': filename,
      'image': image,
      'followers': followers,
      'followings': followings,
      'videos': videos.map((video) => video.toJson()).toList(),
      'likedVideos': likedVideos.map((video) => video.toJson()).toList(),
    };
  }
}
