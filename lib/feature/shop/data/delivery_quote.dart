class DeliveryQuote {
  final double amount;
  final Map<String, DateTime>? estimatedTimeline;

  DeliveryQuote({
    required this.amount,
    this.estimatedTimeline,
  });

  factory DeliveryQuote.fromJson(Map<String, dynamic> json) {
    final timeline = json['estimatedTimeline'] as Map<String, dynamic>?;
    return DeliveryQuote(
      amount: (json['amount'] as num).toDouble(),
      estimatedTimeline: timeline != null
          ? {
              'pickup': DateTime.parse(timeline['pickup']),
              'dropoff': DateTime.parse(timeline['dropoff']),
              'completed': DateTime.parse(timeline['completed']),
            }
          : null,
    );
  }
}
