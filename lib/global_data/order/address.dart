class Address {
  final String? id;
  final String userId;
  final String name;
  final String phone;
  final String value;
  final double latitude;
  final double longitude;

  Address({
    this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.value,
    required this.latitude,
    required this.longitude,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'phone': phone,
      'value': value,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
