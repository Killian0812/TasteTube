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
}

class CartItem {
  String id;
  Product product;
  int quantity;
  double cost;
  String currency;

  CartItem({
    required this.id,
    required this.product,
    required this.quantity,
    required this.cost,
    required this.currency,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      cost: json['cost'] as double,
      currency: json['currency'],
    );
  }
}
