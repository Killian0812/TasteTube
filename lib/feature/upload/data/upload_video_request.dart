class UploadVideoRequest {
  final String title;
  final String description;
  final List<String> hashtags;
  final String direction;
  final String thumbnail;
  final List<String> products; // TODO: change to Product model
  final String visibility;

  const UploadVideoRequest(
    this.title,
    this.description,
    this.hashtags,
    this.direction,
    this.thumbnail,
    this.products,
    this.visibility,
  );

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'hashtags': hashtags,
      'direction': direction,
      'thumbnail': thumbnail,
      'products': products,
      'visibility': visibility,
    };
  }
}
