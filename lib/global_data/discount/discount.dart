class Discount {
  final String id;
  final String shopId;
  final String code;
  final String type; // 'fixed' or 'percentage'
  final double value;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int? maxUses;
  final int? usesPerUser;
  final double? minOrderAmount;
  final List<String> productIds;
  final List<String> userUsedIds;

  Discount({
    required this.id,
    required this.shopId,
    required this.code,
    required this.type,
    required this.value,
    this.description,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.maxUses,
    this.usesPerUser,
    this.minOrderAmount,
    required this.productIds,
    required this.userUsedIds,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      id: json['_id'],
      shopId: json['shopId'],
      code: json['code'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      description: json['description'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'],
      maxUses: json['maxUses'],
      usesPerUser: json['usesPerUser'],
      minOrderAmount: json['minOrderAmount'] != null
          ? (json['minOrderAmount'] as num).toDouble()
          : null,
      productIds: List<String>.from(json['productIds'] ?? []),
      userUsedIds: List<String>.from(
          json['userUsages']?.map((usage) => usage['userId']) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'code': code,
      'type': type,
      'value': value,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'maxUses': maxUses,
      'usesPerUser': usesPerUser,
      'minOrderAmount': minOrderAmount,
      'productIds': productIds,
      'userUsages':
          userUsedIds.map((userId) => {'userId': userId, 'count': 0}).toList(),
    };
  }
}
