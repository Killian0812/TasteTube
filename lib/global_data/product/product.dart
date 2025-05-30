import 'package:taste_tube/global_data/order/address.dart';

class Product {
  final String id;
  final String userId;
  final String userImage;
  final String username;
  final String? userPhone;
  final String name;
  final double cost;
  final String currency;
  final bool ship;
  final String? description;
  final int quantity;
  final String? categoryName;
  final String? categoryId;
  final List<ImageData> images;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? prepTime;
  final double? distance;
  final Address? shopAddress;

  Product({
    required this.id,
    required this.userId,
    required this.userImage,
    required this.username,
    this.userPhone,
    required this.name,
    required this.cost,
    required this.currency,
    required this.ship,
    this.description,
    required this.quantity,
    this.categoryName,
    this.categoryId,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
    this.prepTime,
    this.distance,
    this.shopAddress,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['_id'] as String,
        userId: json['userId']['_id'] as String,
        userImage: json['userId']['image'] as String,
        username: json['userId']['username'] as String,
        userPhone: json['userId']['phone'] as String?,
        name: json['name'] as String,
        cost: (json['cost'] as num).toDouble(),
        currency: json['currency'] as String,
        ship: json['ship'] as bool,
        description: json['description'] as String?,
        quantity: json['quantity'] as int,
        categoryName: json['category']['name'] as String?,
        categoryId: json['category']['_id'] as String?,
        images: (json['images'] as List<dynamic>)
            .map((image) => ImageData.fromJson(image))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        prepTime: json['prepTime'] as int?,
        distance: (json['distance'] as num?)?.toDouble(),
        shopAddress: json['shopAddress'] != null
            ? Address.fromJson(json['shopAddress'] as Map<String, dynamic>)
            : null);
  }
}

class ImageData {
  final String url;
  final String filename;

  ImageData({
    required this.url,
    required this.filename,
  });

  factory ImageData.fromJson(Map<String, dynamic> json) {
    return ImageData(
      url: json['url'] as String,
      filename: json['filename'] as String,
    );
  }
}
