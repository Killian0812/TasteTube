class Api {
  // exposed local server to internet using ngrok
  static const _baseUrl = 'https://1e0b-27-73-139-80.ngrok-free.app/api';

  static const loginApi = '$_baseUrl/auth';
  static const registerApi = '$_baseUrl/register';
  static const refreshApi = '$_baseUrl/refresh';
}