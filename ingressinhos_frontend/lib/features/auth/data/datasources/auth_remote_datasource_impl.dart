import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
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
    final response = await _authDioClient.dio.post(
      Endpoints.authLogin,
      data: {
        'email': email,
        'password': password,
      },
    );

    return AuthTokens(
      token: response.data['token'],
      refreshToken: response.data['refreshToken'],
    );
  } on DioException catch (e) {
    final data = e.response?.data;

    if (data is List && data.isNotEmpty) {
      final message = data[0]['mensagem'];

      throw Exception(message);
    }

    if (data is Map && data.containsKey('message')) {
      throw Exception(data['message']);
    }

    throw Exception('Erro ao fazer login');
  }
}

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String cpf,
  }) async {
    try {
      await _ingressinhosClient.dio.post(
        Endpoints.authRegister,
        data: {'name': name, 'email': email, 'password': password, 'cpf': cpf},
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is List && data.isNotEmpty) {
        final message = data[0]['mensagem'];

        throw Exception(message);
      }

      throw Exception('Erro ao cadastrar usuário');
    }
  }

  @override
  Future<AuthTokens> refreshToken({required String token, required String refreshToken}) async {
    try {
      final response = await _authDioClient.dio.post(
        Endpoints.authRefreshToken,
        data: {'token': token,'refreshToken': refreshToken},
      );

      return AuthTokens(
        token: response.data['token'],
        refreshToken: response.data['refreshToken'],
      );
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is List && data.isNotEmpty) {
        final message = data[0]['mensagem'];

        throw Exception(message);
      }

      throw Exception('Erro ao atualizar token');
    }
  }
}
