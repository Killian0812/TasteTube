class Video {
  String userId;
  String url;
  String filename;
  String? direction;
  String? title;
  String? description;
  String? thumbnail;
  List<String>? hashtags;
  int likes;
  int comments;
  String visibility;
  DateTime createdAt;
  DateTime updatedAt;

  Video({
    required this.userId,
    required this.url,
    required this.filename,
    this.direction,
    this.title,
    this.description,
    this.thumbnail,
    this.hashtags,
    required this.likes,
    required this.comments,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      userId: json['userId'],
      url: json['url'],
      filename: json['filename'],
      direction: json['direction'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: (json['likes'] as List<dynamic>).length,
      comments: (json['comments'] as List<dynamic>).length,
      visibility: json['visibility'] ?? 'PUBLIC',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'url': url,
      'filename': filename,
      'direction': direction,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'hashtags': hashtags,
      'likes': likes,
      'comments': comments,
      'visibility': visibility,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
