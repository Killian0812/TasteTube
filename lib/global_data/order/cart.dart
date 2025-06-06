import 'package:taste_tube/global_data/product/product.dart';

class Cart {
  String id;
  String userId;
  List<CartItem> items;
  DateTime createdAt;
  DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'],
      userId: json['userId'],
      items: (json['items'] as List<dynamic>)
          .map(
              (itemJson) => CartItem.fromJson(itemJson as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Cart clone() {
    return Cart(
      id: id,
      userId: userId,
      items: List.from(items),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class CartItem {
  String id;
  Product product;
  String? size;
  List<ToppingOption> toppings;
  int quantity;
  double cost;
  String currency;

  CartItem({
    required this.id,
    required this.product,
    this.size,
    required this.toppings,
    required this.quantity,
    required this.cost,
    required this.currency,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      size: json['size'] as String?,
      toppings: (json['toppings'] as List<dynamic>? ?? [])
          .map((e) => ToppingOption.fromJson(e))
          .toList(),
      quantity: json['quantity'] as int,
      cost: (json['cost'] as num).toDouble(),
      currency: json['currency'],
    );
  }
}
