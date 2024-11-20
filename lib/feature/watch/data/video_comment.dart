class VideoComment {
  String userId;
  String username;
  String avatar;
  String text;

  VideoComment({
    required this.userId,
    required this.username,
    required this.avatar,
    required this.text,
  });

  factory VideoComment.fromJson(Map<String, dynamic> json) {
    return VideoComment(
      userId: json['userId'],
      username: json['username'],
      avatar: json['avatar'],
      text: json['text'],
    );
  }
}
