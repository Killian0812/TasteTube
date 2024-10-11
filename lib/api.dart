class Api {
  // exposed local server to internet using ngrok
  static const _baseUrl = 'https://7694-27-73-139-80.ngrok-free.app/api';

  static const loginApi = '$_baseUrl/login';
  static const registerApi = '$_baseUrl/register';
}