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

  Future<bool> isLoggedIn();

  Future<void> logout();
}