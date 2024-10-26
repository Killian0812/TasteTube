import 'dart:convert';

class User {
  final String phone;
  final String email;
  final String username;
  final String filename;
  final String image;
  final List<String>? followers;
  final List<String>? followings;
  final List<String> videos;
  final List<String> likedVideos;

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
      phone: json['phone'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      filename: json['filename'] as String,
      image: json['image'] as String,
      followers: List<String>.from(jsonDecode(json['followers']) ?? []),
      followings: List<String>.from(jsonDecode(json['followings']) ?? []),
      videos: List<String>.from(jsonDecode(json['videos'])),
      likedVideos: List<String>.from(jsonDecode(json['likedVideos'])),
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
      'videos': videos,
      'likedVideos': likedVideos,
    };
  }
}
