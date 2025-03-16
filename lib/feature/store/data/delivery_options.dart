class DeliveryOptions {
  final double feePerKm;
  final double minimumOrder;
  final double maxDistance;
  final bool isActive;
  final String currency;

  DeliveryOptions({
    required this.feePerKm,
    required this.minimumOrder,
    required this.maxDistance,
    required this.isActive,
    required this.currency,
  });

  DeliveryOptions copyWith({
    double? feePerKm,
    double? minimumOrder,
    double? maxDistance,
    bool? isActive,
    String? currency,
  }) {
    return DeliveryOptions(
      feePerKm: feePerKm ?? this.feePerKm,
      minimumOrder: minimumOrder ?? this.minimumOrder,
      maxDistance: maxDistance ?? this.maxDistance,
      isActive: isActive ?? this.isActive,
      currency: currency ?? this.currency,
    );
  }
}