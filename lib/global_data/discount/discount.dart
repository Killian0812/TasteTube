class Discount {
  final String id;
  final String shopId;
  final String name;
  final String? code;
  final String type; // 'coupon' or 'voucher'
  final double value;
  final String valueType; // 'fixed' or 'percentage'
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status; // 'active', 'inactive', 'expired'
  final int? maxUses;
  final int? usesPerUser;
  final double? minOrderAmount;
  final List<String> productIds;
  final List<String> userUsedIds;

  Discount({
    required this.id,
    required this.shopId,
    required this.name,
    this.code,
    required this.type,
    required this.value,
    required this.valueType,
    this.description,
    this.startDate,
    this.endDate,
    required this.status,
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
      name: json['name'],
      code: json['code'],
      type: json['type'],
      value: (json['value'] as num).toDouble(),
      valueType: json['valueType'],
      description: json['description'],
      startDate:
          json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'],
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
      'name': name,
      'code': code,
      'type': type,
      'value': value,
      'valueType': valueType,
      'description': description,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'maxUses': maxUses,
      'usesPerUser': usesPerUser,
      'minOrderAmount': minOrderAmount,
      'productIds': productIds,
      'userUsages':
          userUsedIds.map((userId) => {'userId': userId, 'count': 0}).toList(),
    };
  }
}
