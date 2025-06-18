class Api {
  static late final String baseUrl;

  // Auth
  static const loginApi = '/auth';
  static const facebookAuthApi = '/auth/facebook';
  static const googleAuthApi = '/auth/google';
  static const phoneAuthApi = '/auth/phone';
  static const otpVerifyApi = '/auth/otp';
  static const registerApi = '/register';
  static const setRoleApi = '/register/set_role';
  static const refreshApi = '/refresh';

  // Features
  // Video
  static const videoApi = '/videos';
  static const ownedVideoApi = '/videos/owned';
  static const likedVideoApi = '/videos/liked';
  static const reviewVideoApi = '/videos/review';
  static const singleVideoApi = '/videos/:videoId';
  static const videoInteractionApi = '/videos/:videoId/interaction';
  static const videoLikeApi = '/videos/:videoId/like';
  static const videoUnlikeApi = '/videos/:videoId/unlike';
  static const videoCommentApi = '/videos/:videoId/comment';
  static const videoShareApi = '/videos/:videoId/share';
  static const videoStatusApi = '/videos/:videoId/status';

  // Product
  static const categoryApi = '/product/categories';
  static const productApi = '/product';

  // Shop
  static const shopRecommendedApi = '/shop/recommended';
  static const shopSearchApi = '/shop/search';
  static const singleShopApi = '/shop/:shopId';
  static const singleShopSearchApi = '/shop/:shopId/search';

  // Cart & Order
  static const orderApi = '/order';
  static const singleOrderApi = '/order/:orderId';
  static const orderStatusApi = '/order/:orderId/status';
  static const customerOrderApi = '/order/customer';
  static const shopOrderApi = '/order/shop';

  static const cartApi = '/cart';
  static const addCartApi = '/cart/add';
  static const updateCartApi = '/cart/update';
  static const orderSummary = '/cart/order-summary';

  static const orderDeliveryQuoteApi = '/order-delivery/:orderId/quote';
  static const orderDeliveryRenewApi = '/order-delivery/:orderId/renew';
  static const orderDeliveryApi = '/order-delivery/:orderId';

  // Feedback
  static const productRatingFeedback = '/feedback/rating';
  static const orderFeedbacks = '/feedback/order/:orderId';
  static const productFeedbacks = '/feedback/product/:productId';

  // Address & Delivery
  static const addressApi = '/address';
  static const singleAddressApi = '/address/:addressId';
  static const deliveryOptionApi = '/delivery/option';

  // Content
  static const searchApi = '/content/search';
  static const feedApi = '/content/feeds';
  static const followingFeedApi = '/content/following';

  // Chat
  static const channelSettings = '/chat/channel/:channelId';

  // Payment
  static const getVnpayUrl = '/payment/vnpay/getUrl';
  static const createCardPayment = '/payment/card';
  static const confirmPayment = '/payment/confirm';

  // Payment options
  static const changeCurrency = '/payment-option/change-currency';
  static const getCards = '/payment-option/cards';
  static const addCard = '/payment-option/add-card';
  static const setDefaultCard = '/payment-option/set-default-card/:cardId';
  static const removeCard = '/payment-option/remove-card/:cardId';

  // Discount
  static const discountApi = '/discount';
  static const discountByCodeApi = '/discount/code/:code';
  static const discountByShopApi = '/discount/shop/:shopId';
  static const discountValidateApi = '/discount/validate';
  static const singleDiscountApi = '/discount/:id';

  // Analytics
  static const analyticByShopApi = '/analytic/shop/:shopId';

  // User
  static const usersApi = '/users';
  static const userApi = '/users/:userId';
  static const changePasswordApi = '/users/:userId/change_password';
  static const followUserApi = '/users/:userId/follow';
  static const unfollowUserApi = '/users/:userId/unfollow';
  static const userStatusApi = '/users/:userId/status';

  factory Api(String environment) {
    switch (environment) {
      case 'ngrok':
        baseUrl = 'https://first-shepherd-legible.ngrok-free.app';
        break;
      case 'vercel':
        baseUrl = 'https://taste-tube-api.vercel.app';
        break;
      case 'localhost':
        baseUrl = 'http://localhost:8080';
        break;
      default:
        throw ArgumentError('Unknown environment: $environment');
    }
    return Api._internal();
  }

  Api._internal();
}
