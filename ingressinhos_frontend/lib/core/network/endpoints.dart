class Endpoints {
  // API Auth
  static const ingressinhosBaseUrl = 'http://10.0.2.2:5202'; // URL base
  static const authBaseUrl = 'http://10.0.2.2:5254'; // URL base para autenticação

  static const authRegister = '/api/clients'; // Para cadastrar usuarios
  static const authLogin = '/api/auth/login'; // Para logar usuarios e obter token
  static const authRefreshToken = '/api/auth/refresh'; // Para dar refresh no token que esta vencido

  // API Ingressinhos
}