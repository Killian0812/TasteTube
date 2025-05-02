class Feedback {
  final String productId;
  final String orderId;
  final String userId;
  final int rating;
  final String? feedback;

  const Feedback({
    required this.productId,
    required this.orderId,
    required this.userId,
    required this.rating,
    this.feedback,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      productId: json['productId'],
      orderId: json['orderId'],
      userId: json['userId'],
      rating: json['rating'],
      feedback: json['feedback'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'orderId': orderId,
      'userId': userId,
      'rating': rating,
      'feedback': feedback,
    };
  }
}
