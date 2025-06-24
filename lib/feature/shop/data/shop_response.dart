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

enum ProductOrderBy { newest, distance, rating }

extension ProductOrderByExt on ProductOrderBy {
  String get value {
    switch (this) {
      case ProductOrderBy.newest:
        return 'newest';
      case ProductOrderBy.distance:
        return 'distance';
      case ProductOrderBy.rating:
        return 'rating';
    }
  }

  String get label {
    switch (this) {
      case ProductOrderBy.newest:
        return 'Newest';
      case ProductOrderBy.distance:
        return 'Nearest';
      case ProductOrderBy.rating:
        return 'Top Rated';
    }
  }
}
