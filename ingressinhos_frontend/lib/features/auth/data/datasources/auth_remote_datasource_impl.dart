import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/domain/entities/auth_tokens.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {

  final AuthDioClient _client;

  AuthRemoteDatasourceImpl(this._client);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.dio.post(Endpoints.authLogin, data: {
      'email': email,
      'password': password,
    });

    return AuthTokens(
      token: response.data['token'],
      refreshToken: response.data['refreshToken'],
    );
  }
  
  @override
  Future<void> register({required String name, required String email, required String password, required String cpf}) async {
    await _client.dio.post(Endpoints.authRegister, data: {
      'name': name,
      'email': email,
      'password': password,
      'cpf': cpf,
    });
  }
}