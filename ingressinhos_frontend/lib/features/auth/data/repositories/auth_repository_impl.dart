import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/domain/enums/auth_type.dart';
import 'package:ingressinhos_frontend/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {

  final AuthRemoteDatasource remoteDatasource;

  final SecureStorageService storage;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.storage,
  });

  @override
  Future<AuthType> isLoggedIn() async{
    final token = await storage.getToken();

    if(token == null) {
      return AuthType.notLoggedIn;
    }

    final refreshToken = await storage.getRefreshToken();

    if(refreshToken == null) {
      return AuthType.notLoggedIn;
    }

    try {
      final newTokens = await remoteDatasource.refreshToken(token: token, refreshToken: refreshToken);

      await storage.saveToken(token: newTokens.token, refreshToken: newTokens.refreshToken);

      return AuthType.loggedIn;
    } catch (e) {
      print(e);
      return AuthType.loggedInWithServerError;
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
  Future<void> registerClient({required String name, required String email, required String password, required String cpf}) async {
    await remoteDatasource.registerClient(name: name, email: email, password: password, cpf: cpf);
  }

  @override
  Future<void> registerSeller({required String name, required String email, required String password, required String cnpj, required String tradingName}) async {
    await remoteDatasource.registerSeller(name: name, email: email, password: password, cnpj: cnpj, tradingName: tradingName);
  }
}