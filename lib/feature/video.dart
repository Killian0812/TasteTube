class Video {
  String userId;
  String url;
  String filename;
  String? direction;
  String? title;
  String? description;
  String? thumbnail;
  List<String>? hashtags;
  List<String>? likes;
  List<String>? comments;
  List<String>? products;
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
    this.likes,
    this.comments,
    this.products,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory method to create a Video instance from a map (JSON deserialization)
  factory Video.fromMap(Map<String, dynamic> json) {
    return Video(
      userId: json['userId'],
      url: json['url'],
      filename: json['filename'],
      direction: json['direction'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      likes: List<String>.from((json['likes'] ?? []).json((id) => id)),
      comments: List<String>.from((json['comments'] ?? []).json((id) => id)),
      products: List<String>.from((json['products'] ?? []).json((id) => id)),
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
      'likes': likes?.map((id) => id).toList(),
      'comments': comments?.map((id) => id).toList(),
      'products': products?.map((id) => id).toList(),
      'visibility': visibility,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
