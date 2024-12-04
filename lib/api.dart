class Api {
  // Exposed local server to internet using ngrok
  static const baseUrl = 'https://first-shepherd-legible.ngrok-free.app/api';

  // Auth
  static const loginApi = '/auth';
  static const facebookAuthApi = '/auth/facebook';
  static const googleAuthApi = '/auth/google';
  static const registerApi = '/register';
  static const setRoleApi = '/register/set_role';
  static const refreshApi = '/refresh';

  // Features
  // Video upload
  static const uploadVideoApi = '/videos';
  static const videoApi = '/videos/:videoId';
  static const videoLikeApi = '/videos/:videoId/like';
  static const videoCommentApi = '/videos/:videoId/comment';

  // Product
  static const categoryApi = '/product/categories';
  static const productApi = '/product';

  // Content
  static const searchApi = '/content/search';

  // User
  static const userApi = '/users/:userId';
  static const changePasswordApi = '/users/:userId/change_password';
  static const followUserApi = '/users/:userId/follow';
  static const unfollowUserApi = '/users/:userId/unfollow';
}
