import 'package:taste_tube/global_data/pagination.dart';
import 'package:taste_tube/global_data/product/product.dart';

class ShopResponse {
  final List<Product> products;
  final Pagination pagination;

  ShopResponse({
    required this.products,
    required this.pagination,
  });

  factory ShopResponse.fromJson(Map<String, dynamic> json) {
    return ShopResponse(
      products: (json['docs'] as List<dynamic>)
          .map((e) => Product.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json),
    );
  }
}
