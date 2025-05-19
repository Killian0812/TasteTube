class PhoneOtpResponse {
  final String message;
  final DateTime activatedAt;

  const PhoneOtpResponse({
    required this.message,
    required this.activatedAt,
  });

  factory PhoneOtpResponse.fromJson(Map<String, dynamic> json) {
    return PhoneOtpResponse(
      message: json['message'] as String,
      activatedAt:
          DateTime.fromMillisecondsSinceEpoch(json['activatedAt'] as int),
    );
  }
}
