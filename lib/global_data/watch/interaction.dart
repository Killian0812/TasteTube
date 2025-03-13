class Interaction {
  String videoId;
  int totalLikes;
  int totalViews;
  int totalShares;
  int totalBookmarked;
  bool userLiked;

  Interaction({
    required this.videoId,
    required this.totalLikes,
    required this.totalViews,
    required this.totalShares,
    required this.totalBookmarked,
    required this.userLiked,
  });

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      videoId: json['videoId'],
      totalLikes: json['totalLikes'],
      totalViews: json['totalViews'],
      totalShares: json['totalShares'],
      totalBookmarked: json['totalBookmarked'],
      userLiked: json['userLiked'] as bool,
    );
  }

  Interaction copyWith({
    String? videoId,
    int? totalLikes,
    int? totalViews,
    int? totalShares,
    int? totalBookmarked,
    bool? userLiked,
  }) {
    return Interaction(
      videoId: videoId ?? this.videoId,
      totalLikes: totalLikes ?? this.totalLikes,
      totalViews: totalViews ?? this.totalViews,
      totalShares: totalShares ?? this.totalShares,
      totalBookmarked: totalBookmarked ?? this.totalBookmarked,
      userLiked: userLiked ?? this.userLiked,
    );
  }
}
