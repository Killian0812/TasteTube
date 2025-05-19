class PhoneOtpRequest {
  final String phone;

  const PhoneOtpRequest(this.phone);

  Map<String, dynamic> toJson() => {
        'phone': phone,
      };
}

class ContinueWithOtpRequest {
  final String phone;
  final String otp;

  const ContinueWithOtpRequest(this.phone, this.otp);

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otp': otp,
      };
}
