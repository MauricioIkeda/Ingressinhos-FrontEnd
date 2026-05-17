import 'package:ingressinhos_frontend/features/auth/domain/entities/auth_tokens.dart';

abstract class AuthRemoteDatasource {
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

  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<AuthTokens> refreshToken({
    required String token,
    required String refreshToken,
  });
}