import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/product/product.dart';

class SingleShopResponse {
  final List<Product> products;
  final Address? shopAddress;

  SingleShopResponse({
    required this.products,
    this.shopAddress,
  });

  factory SingleShopResponse.fromJson(Map<String, dynamic> json) {
    return SingleShopResponse(
      products: (json['products'] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList(),
      shopAddress: json['shopAddress'] != null
          ? Address.fromJson(json['shopAddress'] as Map<String, dynamic>)
          : null,
    );
  }
}
