enum AccountType { restaurant, customer }

extension AccountTypeExtension on AccountType {
  String value() {
    switch (this) {
      case AccountType.restaurant:
        return "RESTAURANT";
      case AccountType.customer:
        return "CUSTOMER";
    }
  }
}

enum Visibility { private, followersOnly, public }

extension VisibilityExtension on Visibility {
  String value() {
    switch (this) {
      case Visibility.private:
        return "PRIVATE";
      case Visibility.followersOnly:
        return "FOLLOWERS_ONLY";
      case Visibility.public:
        return "PUBLIC";
    }
  }

  String name() {
    switch (this) {
      case Visibility.private:
        return "Private";
      case Visibility.followersOnly:
        return "Followers only";
      case Visibility.public:
        return "Public";
    }
  }

  String description() {
    switch (this) {
      case Visibility.private:
        return "Only you can see this video.";
      case Visibility.followersOnly:
        return "Only your & your followers can see this video.";
      case Visibility.public:
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
