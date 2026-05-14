import 'package:ingressinhos_frontend/features/auth/domain/enums/auth_type.dart';

abstract class AuthRepository {
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
  });

  Future<void> login({
    required String email,
    required String password,
  });

  Future<AuthType> isLoggedIn();

  Future<void> logout();
}