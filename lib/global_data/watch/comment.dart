class Comment {
  String id;
  String userId;
  String username;
  String avatar;
  String text;
  DateTime createdAt;
  String? parentCommentId;
  List<Comment> replies;

  Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.avatar,
    required this.text,
    required this.createdAt,
    this.parentCommentId,
    required this.replies,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      userId: json['userId']['_id'],
      username: json['userId']['username'],
      avatar: json['userId']['image'],
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
      parentCommentId: json['parentCommentId'],
      replies: (json['replies'] as List<dynamic>)
          .map((comment) => Comment.fromJson(comment as Map<String, dynamic>))
          .toList(),
    );
  }
}
