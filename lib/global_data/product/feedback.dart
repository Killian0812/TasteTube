import 'package:taste_tube/global_data/user/user_basic.dart';

class Feedback {
  final String productId;
  final String orderId;
  final UserBasic user;
  final int rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Feedback({
    required this.productId,
    required this.orderId,
    required this.user,
    required this.rating,
    this.feedback,
    required this.createdAt,
    required this.updatedAt,
  });

  String? get text {
    if (feedback == null || feedback!.isEmpty) {
      return null;
    }
    return feedback;
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      productId: json['productId'],
      orderId: json['orderId'],
      user: UserBasic.fromJson(json['userId']),
      rating: json['rating'],
      feedback: json['feedback'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'orderId': orderId,
      'userId': user.id,
      'rating': rating,
      'feedback': feedback,
    };
  }
}

typedef ProductFeedback = Feedback;
