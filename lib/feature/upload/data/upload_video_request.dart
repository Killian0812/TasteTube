import 'dart:convert';

class UploadVideoRequest {
  final String title;
  final String description;
  final List<String> hashtags;
  final String direction;
  final String thumbnail;
  final List<String> productIds;
  final String visibility;
  final String? targetUserId;

  const UploadVideoRequest(
    this.title,
    this.description,
    this.hashtags,
    this.direction,
    this.thumbnail,
    this.productIds,
    this.visibility,
    this.targetUserId,
  );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'hashtags': jsonEncode(hashtags),
      'direction': direction,
      'thumbnail': thumbnail,
      'productIds': jsonEncode(productIds),
      'visibility': visibility,
      if (targetUserId != null) 'targetUserId': targetUserId,
    };
  }
}
