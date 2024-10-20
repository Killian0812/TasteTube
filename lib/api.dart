class Api {
  // Exposed local server to internet using ngrok
  static const baseUrl = 'https://first-shepherd-legible.ngrok-free.app/api';

  // Auth
  static const loginApi = '/auth';
  static const registerApi = '/register';
  static const setRoleApi = '/register/set_role';
  static const refreshApi = '/refresh';

  // Features
  static const uploadVideoApi = '/videos';
}
