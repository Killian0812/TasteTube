class PaymentCard {
  final String id;
  final String type;
  final String lastFour;
  final String holderName;
  final String expiryDate;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.type,
    required this.lastFour,
    required this.holderName,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] as String,
      type: json['type'] as String,
      lastFour: json['lastFour'] as String,
      holderName: json['holderName'] as String,
      expiryDate: json['expiryDate'] as String,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
