import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/product/product.dart';
import 'package:taste_tube/global_data/user/user_basic.dart';

class OrderProduct {
  final Product product;
  final int quantity;

  const OrderProduct({
    required this.product,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      product: Product.fromJson(json['product']),
      quantity: json['quantity'],
    );
  }
}

class Order {
  final UserBasic user;
  final String shopId;
  final int orderNum;
  final String orderId;
  final double total;
  final Address address;
  final String notes;
  final List<OrderProduct> items;
  final String paymentMethod;
  final bool paid;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.orderId,
    required this.user,
    required this.shopId,
    required this.orderNum,
    required this.total,
    required this.address,
    required this.notes,
    required this.items,
    required this.paymentMethod,
    required this.paid,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      user: UserBasic.fromJson(json['userId']),
      shopId: json['shopId'],
      orderNum: json['orderNum'],
      total: json['total'],
      address: Address.fromJson(json['address']),
      notes: json['notes'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderProduct.fromJson(item))
          .toList(),
      paymentMethod: json['paymentMethod'],
      paid: json['paid'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
