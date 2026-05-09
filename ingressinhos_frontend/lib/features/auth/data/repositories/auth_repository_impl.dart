import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';

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

    return token != null;
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