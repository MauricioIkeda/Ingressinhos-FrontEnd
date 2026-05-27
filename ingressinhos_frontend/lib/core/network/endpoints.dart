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
  static String get ingressinhosBaseUrl => 'https://example.invalid'; // verdadeiro http://$baseHost:5202
  static String get authBaseUrl => 'https://example.invalid/auth'; // verdadeiro http://$baseHost:5254

  static const authClientRegister = '/api/clients'; // Para cadastrar usuarios
  static const authSellerRegister = '/api/sellers'; // Para cadastrar vendedores
  static const authLogin = '/api/auth/login'; // Para logar usuarios e obter token
  static const authRefreshToken = '/api/auth/refresh'; // Para dar refresh no token que esta vencido

  // API Ingressinhos
  static const eventos = '/api/events'; // Para buscar eventos
  static const eventsWithTickets = '/api/events/WithTickets';
  static const locations = '/api/locations'; // Para buscar localizações
  static const tickets = '/api/tickets'; // Para buscar tickets
  static const issuedTicketsMe = '/api/issued-tickets/me';
  static const cartItems = '/api/orders/cart/items';
  static String cartByClient(int clientId) => '/api/orders/cart/$clientId';
  static String cartItemById(int orderItemId) =>
      '/api/orders/cart/items/$orderItemId';
  static String cartReset(int clientId) => '/api/orders/cart/reset/$clientId';
  static String cartCheckout(int orderId) => '/api/orders/$orderId/close/';
}
