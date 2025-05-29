class Address {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String value;
  final double latitude;
  final double longitude;
  final bool isDefault;

  Address({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.value,
    required this.latitude,
    required this.longitude,
    required this.isDefault,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      value: json['value'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'value': value,
      'latitude': latitude,
      'longitude': longitude,
      'isDefault': isDefault,
    };
  }
}
