import 'package:taste_tube/global_data/order/address.dart';
import 'package:taste_tube/global_data/product/product.dart';

class Order {
  final String userId;
  final String shopId;
  final int orderNum;
  final String orderId;
  final double total;
  final Address address;
  final String notes;
  final List<Product> products;
  final String paymentMethod;
  final bool paid;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.orderId,
    required this.userId,
    required this.shopId,
    required this.orderNum,
    required this.total,
    required this.address,
    required this.notes,
    required this.products,
    required this.paymentMethod,
    required this.paid,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      userId: json['userId'],
      shopId: json['shopId'],
      orderNum: json['orderNum'],
      total: json['total'],
      address: Address.fromJson(json['address']),
      notes: json['notes'],
      products: (json['products'] as List<dynamic>)
          .map((item) => Product.fromJson(item))
          .toList(),
      paymentMethod: json['paymentMethod'],
      paid: json['paid'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
