import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDatasource remoteDatasource;

  final SecureStorageService storage;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.storage,
  });

  @override
  Future<bool> isLoggedIn() async{
    final token = await storage.getToken();

    if(token == null) {
      return false;
    }

    final isExpired = JwtDecoder.isExpired(token);

    if(!isExpired) {
      return true;
    }

    final refreshToken = await storage.getRefreshToken();

    if(refreshToken == null) {
      return false;
    }

    try {
      final newTokens = await remoteDatasource.refreshToken(token: token, refreshToken: refreshToken);

      await storage.saveToken(token: newTokens.token, refreshToken: newTokens.refreshToken);

      return true;
    } catch (e) {
      await storage.clearTokens();
      return false;
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    final tokens = await remoteDatasource.login(email: email, password: password);

    await storage.saveToken(token: tokens.token, refreshToken: tokens.refreshToken);
  }

  @override
  Future<void> logout() async {
    await storage.clearTokens();
  }

  @override
  Future<void> register({required String name, required String email, required String password, required String cpf}) async {
    await remoteDatasource.register(name: name, email: email, password: password, cpf: cpf);
  }
}