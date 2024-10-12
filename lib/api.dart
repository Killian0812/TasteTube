class Api {
  // exposed local server to internet using ngrok
  static const _baseUrl = 'http://14.9.0.155:8080/api';

  static const loginApi = '$_baseUrl/login';
  static const registerApi = '$_baseUrl/register';
}