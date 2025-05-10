import 'package:taste_tube/global_data/product/product.dart';

class Video {
  String id;
  String ownerId;
  String ownerUsername;
  String ownerImage;
  String url;
  String? manifestUrl;
  int views;
  String filename;
  String? direction;
  String? title;
  String? description;
  String? thumbnail;
  List<String>? hashtags;
  List<Product> products;
  String visibility;
  String? targetUserId;
  String? targetUsername;
  String? targetUserImage;
  String status;
  DateTime createdAt;
  DateTime updatedAt;

  Video({
    required this.id,
    required this.ownerId,
    required this.ownerUsername,
    required this.ownerImage,
    required this.url,
    required this.filename,
    required this.views,
    this.manifestUrl,
    this.direction,
    this.title,
    this.description,
    this.thumbnail,
    this.hashtags,
    required this.products,
    required this.visibility,
    this.targetUserId,
    this.targetUsername,
    this.targetUserImage,
    required this.status,
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
      views: (json['views'] as num?)?.toInt() ?? 0,
      manifestUrl: json['manifestUrl'] as String?,
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
      visibility: json['visibility'] ?? 'PUBLIC',
      targetUserId: json['targetUserId']?['_id'] as String?,
      targetUsername: json['targetUserId']?['username'] as String?,
      targetUserImage: json['targetUserId']?['image'] as String?,
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class VideoResponse {
  final List<Video> videos;
  final int totalDocs;
  final int limit;
  final bool hasPrevPage;
  final bool hasNextPage;
  final int page;
  final int totalPages;
  final int? prevPage;
  final int? nextPage;

  const VideoResponse({
    required this.videos,
    required this.totalDocs,
    required this.limit,
    required this.hasPrevPage,
    required this.hasNextPage,
    required this.page,
    required this.totalPages,
    this.prevPage,
    this.nextPage,
  });

  factory VideoResponse.fromJson(Map<String, dynamic> json) {
    return VideoResponse(
      videos: (json['videos'] as List<dynamic>)
          .map((videoJson) => Video.fromJson(videoJson as Map<String, dynamic>))
          .toList(),
      totalDocs: json['totalDocs'] as int,
      limit: json['limit'] as int,
      hasPrevPage: json['hasPrevPage'] as bool,
      hasNextPage: json['hasNextPage'] as bool,
      page: json['page'] as int,
      totalPages: json['totalPages'] as int,
      prevPage: json['prevPage'] as int?,
      nextPage: json['nextPage'] as int?,
    );
  }
}
