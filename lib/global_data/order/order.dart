import 'package:taste_tube/global_data/discount/discount.dart';
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
  final String id;
  final UserBasic user;
  final String shopId;
  final int orderNum;
  final String trackingId;
  final String orderId;
  final double total;
  final double deliveryFee;
  final Address address;
  final String notes;
  final List<OrderProduct> items;
  final List<AppliedDiscount> discounts;
  final String paymentMethod;
  final bool paid;
  final String status;
  final String? deliveryType;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.orderId,
    required this.trackingId,
    required this.user,
    required this.shopId,
    required this.orderNum,
    required this.total,
    required this.deliveryFee,
    required this.address,
    required this.notes,
    required this.items,
    required this.discounts,
    required this.paymentMethod,
    required this.paid,
    required this.status,
    required this.deliveryType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      orderId: json['orderId'],
      trackingId: json['trackingId'],
      user: UserBasic.fromJson(json['userId']),
      shopId: json['shopId'],
      orderNum: json['orderNum'],
      total: json['total'] * 1.0,
      deliveryFee: json['deliveryFee'] * 1.0,
      address: Address.fromJson(json['address']),
      notes: json['notes'],
      items: (json['items'] as List<dynamic>)
          .map((item) => OrderProduct.fromJson(item))
          .toList(),
      discounts: (json['discounts'] as List<dynamic>)
          .map((item) => AppliedDiscount.fromJson(item))
          .toList(),
      paymentMethod: json['paymentMethod'],
      paid: json['paid'],
      status: json['status'],
      deliveryType: json['deliveryType'] as String?,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class OrderSummary {
  final String shopId;
  final double? deliveryFee;
  final double? totalDiscountAmount;
  final Map<String, double>? discountDetails;
  final double? totalAmount;
  final String? message;

  const OrderSummary({
    required this.shopId,
    required this.deliveryFee,
    required this.totalDiscountAmount,
    required this.discountDetails,
    required this.totalAmount,
    required this.message,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      shopId: json['shopId'],
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble(),
      totalDiscountAmount: (json['totalDiscountAmount'] as num?)?.toDouble(),
      discountDetails: (json['discountDetails'] as Map<String, dynamic>?)
          ?.map((key, value) => MapEntry(key, (value as num).toDouble())),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['shopId'] = shopId;
    if (deliveryFee != null) map['deliveryFee'] = deliveryFee;
    if (totalDiscountAmount != null) {
      map['totalDiscountAmount'] = totalDiscountAmount;
    }
    if (discountDetails != null) map['discountDetails'] = discountDetails;
    if (totalAmount != null) map['totalAmount'] = totalAmount;
    if (message != null) map['message'] = message;
    return map;
  }
}
