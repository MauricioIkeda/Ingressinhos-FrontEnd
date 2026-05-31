import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/auth_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/domain/entities/auth_tokens.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final AuthDioClient _authDioClient;
  final IngressinhosDioClient _ingressinhosClient;

  AuthRemoteDatasourceImpl(this._authDioClient, this._ingressinhosClient);

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final authorizeResponse = await _authDioClient.dio.post(
        Endpoints.authAuthorize,
        data: {
          'email': email,
          'password': password,
          'clientId': 'ingressinhos-api',
          'redirectUri': 'ingressinhos://auth/callback',
          'state': 'ingressinhos',
        },
      );

      final tokenResponse = await _authDioClient.dio.post(
        Endpoints.authToken,
        data: {
          'code': authorizeResponse.data['code'],
          'clientId': 'ingressinhos-api',
          'redirectUri': 'ingressinhos://auth/callback',
        },
      );

      return AuthTokens(
        token: tokenResponse.data['accessToken'] ?? tokenResponse.data['token'],
        refreshToken: tokenResponse.data['refreshToken'],
      );
    } on DioException catch (e) {
      throw AuthException(mapDioError(e, 'Erro ao fazer login'));
    }
  }

  @override
  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    required String cpf,
  }) async {
    try {
      await _ingressinhosClient.dio.post(
        Endpoints.authClientRegister,
        data: {'name': name, 'email': email, 'password': password, 'cpf': cpf},
      );
    } on DioException catch (e) {
      throw AuthException(mapDioError(e, 'Erro ao cadastrar usuario'));
    }
  }

  @override
  Future<void> registerSeller({
    required String name,
    required String email,
    required String password,
    required String cnpj,
    required String tradingName,
  }) async {
    try {
      await _ingressinhosClient.dio.post(
        Endpoints.authSellerRegister,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'cnpj': cnpj,
          'tradingName': tradingName,
        },
      );
    } on DioException catch (e) {
      throw AuthException(mapDioError(e, 'Erro ao cadastrar vendedor'));
    }
  }

  @override
  Future<AuthTokens> refreshToken({
    required String token,
    required String refreshToken,
  }) async {
    try {
      final response = await _authDioClient.dio.post(
        Endpoints.authRefreshToken,
        data: {'refreshToken': refreshToken},
      );

      return AuthTokens(
        token: response.data['accessToken'] ?? response.data['token'],
        refreshToken: response.data['refreshToken'],
      );
    } on DioException catch (e) {
      throw AuthException(mapDioError(e, 'Erro ao atualizar token'));
    }
  }
}
