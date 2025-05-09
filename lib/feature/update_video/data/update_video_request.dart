class UpdateVideoRequest {
  final String? title;
  final String? description;
  final List<String>? hashtags;
  final List<String>? productIds;
  final String? visibility;

  UpdateVideoRequest(
    this.title,
    this.description,
    this.hashtags,
    this.productIds,
    this.visibility,
  );

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (hashtags != null) 'hashtags': hashtags,
        if (productIds != null) 'productIds': productIds,
        if (visibility != null) 'visibility': visibility,
      };
}
