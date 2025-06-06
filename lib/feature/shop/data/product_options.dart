import 'package:taste_tube/global_data/product/product.dart';

class ProductOptions {
  final int quantity;
  final String? size;
  final List<ToppingOption> toppings;

  ProductOptions({
    required this.quantity,
    this.size,
    required this.toppings,
  });

  Map<String, dynamic> toJson() {
    return {
      'quantity': quantity,
      'size': size,
      'toppings': toppings.map((t) => t.toJson()).toList(),
    };
  }

  ProductOptions copyWith({
    int? quantity,
    String? size,
    List<ToppingOption>? toppings,
  }) {
    return ProductOptions(
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      toppings: toppings ?? this.toppings,
    );
  }
}
