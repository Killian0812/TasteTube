class Api {
  // Exposed local server to internet using ngrok
  static const baseUrl = 'https://first-shepherd-legible.ngrok-free.app';

  // Auth
  static const loginApi = '/auth';
  static const facebookAuthApi = '/auth/facebook';
  static const googleAuthApi = '/auth/google';
  static const registerApi = '/register';
  static const setRoleApi = '/register/set_role';
  static const refreshApi = '/refresh';

  // Features
  // Video
  static const uploadVideoApi = '/videos';
  static const likedVideoApi = '/videos/liked';
  static const reviewVideoApi = '/videos/review';
  static const videoApi = '/videos/:videoId';
  static const videoLikeApi = '/videos/:videoId/like';
  static const videoUnlikeApi = '/videos/:videoId/unlike';
  static const videoCommentApi = '/videos/:videoId/comment';

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
  static const singleOrderApi = '/order/:id';
  static const customerOrderApi = '/order/customer';
  static const shopOrderApi = '/order/shop';
  static const cartApi = '/cart';
  static const addCartApi = '/cart/add';
  static const updateCartApi = '/cart/update';

  // Address
  static const addressApi = '/address';
  static const singleAddressApi = '/address/:addressId';

  // Content
  static const searchApi = '/content/search';
  static const feedApi = '/content/feeds';

  // Payment
  static const getVnpayUrl = '/payment/vnpay/getUrl';

  // User
  static const userApi = '/users/:userId';
  static const changePasswordApi = '/users/:userId/change_password';
  static const followUserApi = '/users/:userId/follow';
  static const unfollowUserApi = '/users/:userId/unfollow';
}
