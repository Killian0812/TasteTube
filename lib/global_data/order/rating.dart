
class Rating {
  final String productId;
  final String orderId;
  final String userId;
  final int rating;
  final String? feedback;

  const Rating({
    required this.productId,
    required this.orderId,
    required this.userId,
    required this.rating,
    this.feedback,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      productId: json['productId'],
      orderId: json['orderId'],
      userId: json['userId'],
      rating: json['rating'],
      feedback: json['feedback'] as String?,
    );
  }
}
