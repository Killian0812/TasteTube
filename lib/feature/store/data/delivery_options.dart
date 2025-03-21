import 'package:taste_tube/global_data/order/address.dart';

class DeliveryOption {
  final String shopId;
  final double freeDistance;
  final double feePerKm;
  final double maxDistance;
  final Address? address;

  DeliveryOption({
    required this.shopId,
    required this.freeDistance,
    required this.feePerKm,
    required this.maxDistance,
    this.address,
  });

  factory DeliveryOption.fromJson(Map<String, dynamic> json) {
    return DeliveryOption(
      shopId: json['shopId'],
      freeDistance: (json['freeDistance'] as num).toDouble(),
      feePerKm: (json['feePerKm'] as num).toDouble(),
      maxDistance: (json['maxDistance'] as num).toDouble(),
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopId': shopId,
      'freeDistance': freeDistance,
      'feePerKm': feePerKm,
      'maxDistance': maxDistance,
      'address': address?.id,
    };
  }
}
