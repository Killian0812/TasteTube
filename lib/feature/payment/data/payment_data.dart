import 'package:taste_tube/common/constant.dart';

enum PaymentMethod {
  VNPAY,
  ZALOPAY,
  COD,
  CARD,
}

extension PaymentMethodExtension on PaymentMethod {
  String get assetPath {
    switch (this) {
      case PaymentMethod.VNPAY:
        return AssetPath.vnpay;
      case PaymentMethod.ZALOPAY:
        return AssetPath.zalopay;
      case PaymentMethod.COD:
        return AssetPath.cod;
      default:
        return AssetPath.cod;
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.VNPAY:
        return 'VNPay';
      case PaymentMethod.ZALOPAY:
        return 'ZaloPay';
      case PaymentMethod.COD:
        return 'Cash on Delivery (COD)';
      case PaymentMethod.CARD:
        return 'Card';
    }
  }

  String get value {
    return name;
  }
}
