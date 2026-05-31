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

  // APIs expostas pelo docker-compose
  static String get ingressinhosBaseUrl => 'http://$baseHost:5202';
  static String get authBaseUrl => 'http://$baseHost:5254';
  static String get sentinelAuthFrontendUrl => 'http://$baseHost:5173';

  static const authClientRegister = '/api/clients'; // Para cadastrar usuarios
  static const authSellerRegister = '/api/sellers'; // Para cadastrar vendedores
  static const authLogin =
      '/api/User/login'; // Para logar usuarios e obter token
  static const authRefreshToken =
      '/api/User/refresh'; // Para dar refresh no token que esta vencido
  static const authAuthorize = '/api/oauth/authorize';
  static const authToken = '/api/oauth/token';
  static const authClientId = 'ingressinhos-api';
  static const authRedirectUri = 'ingressinhos://auth/callback';

  // API Ingressinhos
  static const eventos = '/api/events'; // Para buscar eventos
  static const eventsWithTickets = '/api/events/WithTickets';
  static const sellerMe = '/api/sellers/me';
  static const profileStatus = '/api/onboarding/profile-status';
  static const onboardClient = '/api/onboarding/client';
  static const onboardSeller = '/api/onboarding/seller';
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
