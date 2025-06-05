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
  final List<SizeOption> sizes;
  final List<ToppingOption> toppings;

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
    required this.sizes,
    required this.toppings,
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
      categoryName: json['category']?['name'] as String?,
      categoryId: json['category']?['_id'] as String?,
      images: (json['images'] as List<dynamic>)
          .map((image) => ImageData.fromJson(image))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      prepTime: json['prepTime'] as int?,
      distance: (json['distance'] as num?)?.toDouble(),
      shopAddress: json['shopAddress'] != null
          ? Address.fromJson(json['shopAddress'] as Map<String, dynamic>)
          : null,
      sizes: (json['sizes'] as List<dynamic>? ?? [])
          .map((e) => SizeOption.fromJson(e))
          .toList(),
      toppings: (json['toppings'] as List<dynamic>? ?? [])
          .map((e) => ToppingOption.fromJson(e))
          .toList(),
    );
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

class SizeOption {
  final String name;
  final double extraCost;

  SizeOption({
    required this.name,
    required this.extraCost,
  });

  factory SizeOption.fromJson(Map<String, dynamic> json) {
    return SizeOption(
      name: json['name'] as String,
      extraCost: (json['extraCost'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extraCost': extraCost,
    };
  }
}

class ToppingOption {
  final String name;
  final double extraCost;
  final bool? isAvailable;

  ToppingOption({
    required this.name,
    required this.extraCost,
    this.isAvailable,
  });

  factory ToppingOption.fromJson(Map<String, dynamic> json) {
    return ToppingOption(
      name: json['name'] as String,
      extraCost: (json['extraCost'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'extraCost': extraCost,
      'isAvailable': isAvailable ?? true,
    };
  }
}
