import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/product/product.dart';

class SingleShopResponse {
  final List<Product> products;
  final Address? shopAddress;
  final double? distance;

  SingleShopResponse({
    required this.products,
    this.shopAddress,
    this.distance,
  });

  factory SingleShopResponse.fromJson(Map<String, dynamic> json) {
    return SingleShopResponse(
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList(),
      shopAddress: json['shopAddress'] != null
          ? Address.fromJson(json['shopAddress'] as Map<String, dynamic>)
          : null,
      distance: (json['distance'] as num?)?.toDouble(),
    );
  }
}
