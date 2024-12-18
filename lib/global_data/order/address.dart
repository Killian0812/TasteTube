class Address {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String value;
  final double? latitude;
  final double? longitude;

  Address({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.value,
    this.latitude,
    this.longitude,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['_id'],
      userId: json['userId'],
      name: json['name'],
      phone: json['phone'],
      value: json['value'],
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }
}
