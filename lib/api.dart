class Api {
  // exposed local server to internet using ngrok
  static const baseUrl = 'https://e324-27-73-139-80.ngrok-free.app/api';

  // auth related
  static const loginApi = '/auth';
  static const registerApi = '/register';
  static const setRoleApi = '/register/set_role';
  static const refreshApi = '/refresh';
}
