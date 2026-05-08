import 'package:ingressinhos_frontend/features/auth/domain/entities/auth_tokens.dart';

abstract class AuthRemoteDatasource {
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
  });

  Future<AuthTokens> login({
    required String email,
    required String password,
  });
}