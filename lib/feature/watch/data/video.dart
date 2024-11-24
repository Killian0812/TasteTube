import 'package:taste_tube/feature/product/data/product.dart';

class Video {
  String id;
  String ownerId;
  String ownerUsername;
  String ownerImage;
  String url;
  String filename;
  String? direction;
  String? title;
  String? description;
  String? thumbnail;
  List<String>? hashtags;
  List<Product> products;
  bool userLiked;
  int likes;
  int comments;
  String visibility;
  DateTime createdAt;
  DateTime updatedAt;

  Video({
    required this.id,
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerImage,
    required this.url,
    required this.filename,
    this.direction,
    this.title,
    this.description,
    this.thumbnail,
    this.hashtags,
    required this.products,
    required this.userLiked,
    required this.likes,
    required this.comments,
    required this.visibility,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['_id'],
      ownerId: json['userId']['_id'],
      ownerUsername: json['userId']['username'],
      ownerImage: json['userId']['image'],
      url: json['url'],
      filename: json['filename'],
      direction: json['direction'],
      title: json['title'],
      description: json['description'],
      thumbnail: json['thumbnail'],
      hashtags: List<String>.from(json['hashtags'] ?? []),
      products: (json['products'] as List<dynamic>)
          .map((productJson) =>
              Product.fromJson(productJson as Map<String, dynamic>))
          .toList(),
      userLiked: json['userLiked'] as bool,
      likes: (json['likes'] as List<dynamic>).length,
      comments: (json['comments'] as List<dynamic>).length,
      visibility: json['visibility'] ?? 'PUBLIC',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
