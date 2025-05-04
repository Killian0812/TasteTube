enum AccountType { RESTAURANT, CUSTOMER, ADMIN }

extension AccountTypeExtension on AccountType {
  String get value {
    switch (this) {
      case AccountType.RESTAURANT:
        return "RESTAURANT";
      case AccountType.CUSTOMER:
        return "CUSTOMER";
      case AccountType.ADMIN:
        return "ADMIN";
    }
  }
}

enum VideoVisibility { private, followersOnly, public }

extension VisibilityExtension on VideoVisibility {
  String get value {
    switch (this) {
      case VideoVisibility.private:
        return "PRIVATE";
      case VideoVisibility.followersOnly:
        return "FOLLOWERS_ONLY";
      case VideoVisibility.public:
        return "PUBLIC";
    }
  }

  String get name {
    switch (this) {
      case VideoVisibility.private:
        return "Private";
      case VideoVisibility.followersOnly:
        return "Followers only";
      case VideoVisibility.public:
        return "Public";
    }
  }

  String get description {
    switch (this) {
      case VideoVisibility.private:
        return "Only you can see this video.";
      case VideoVisibility.followersOnly:
        return "Only your & your followers can see this video.";
      case VideoVisibility.public:
        return "Everyone can see this video.";
    }
  }
}

enum OrderStatus { PENDING, CONFIRMED, DELIVERY, COMPLETED, CANCELED }

class AssetPath {
  static const String tastetubeInverted =
      'assets/images/tastetube_inverted.png';
  static const String tastetube = 'assets/images/tastetube.png';
  static const String cod = 'assets/images/cod.png';
  static const String vnpay = 'assets/images/vnpay.jpg';
  static const String zalopay = 'assets/images/zalopay.png';
  static const String grab = 'assets/images/grab.png';
  static const String visa = 'assets/images/visa.png';
  static const String mastercard = 'assets/images/mastercard.png';
  static const String americanExpress = 'assets/images/amex.png';
  static const String unionpay = 'assets/images/unionpay.png';
  static const String discover = 'assets/images/discover.png';
}

Map<String, String> cardAssetPath = {
  'Visa': AssetPath.visa,
  'Mastercard': AssetPath.mastercard,
  'American Express': AssetPath.americanExpress,
  'Discover': AssetPath.discover,
  'UnionPay': AssetPath.unionpay,
  'Card': AssetPath.tastetube
};
