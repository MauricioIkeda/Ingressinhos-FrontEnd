import 'dart:io';

class Endpoints {
  // Android = 10.0.2.2
  // iOS/macOS/web/desktop = localhost
  static String get baseHost {
    if (Platform.isAndroid) {
      return '10.0.2.2';
    }
    return 'localhost';
  }

  // API Auth
  static String get ingressinhosBaseUrl => 'http://$baseHost:5202';
  static String get authBaseUrl => 'http://$baseHost:5254';

  static const authRegister = '/api/clients'; // Para cadastrar usuarios
  static const authLogin = '/api/auth/login'; // Para logar usuarios e obter token
  static const authRefreshToken = '/api/auth/refresh'; // Para dar refresh no token que esta vencido

  // API Ingressinhos
}