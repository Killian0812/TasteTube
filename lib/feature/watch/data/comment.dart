class Comment {
  String id;
  String userId;
  String username;
  String avatar;
  String text;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      userId: json['userId']['_id'],
      username: json['userId']['username'],
      avatar: json['userId']['image'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
