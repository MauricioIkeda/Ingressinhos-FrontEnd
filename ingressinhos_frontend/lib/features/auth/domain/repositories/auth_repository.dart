import 'package:ingressinhos_frontend/features/auth/domain/enums/auth_type.dart';

abstract class AuthRepository {
  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    required String cpf,
  });

  Future<void> registerSeller({
    required String name,
    required String email,
    required String password,
    required String cnpj,
    required String tradingName
  });

  Future<void> login({
    required String email,
    required String password,
  });

  Future<void> completeOAuthLogin({
    required String code,
  });

  Future<AuthType> isLoggedIn();

  Future<void> logout();
}
