import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/network/clients/auth_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/auth_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/domain/entities/auth_tokens.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final AuthDioClient _authDioClient;
  final IngressinhosDioClient _ingressinhosClient;

  AuthRemoteDatasourceImpl(this._authDioClient, this._ingressinhosClient);

  String _mapDioError(DioException e, String fallbackMessage) {
    if (e.type == DioExceptionType.connectionError) {
      return 'Nao foi possivel conectar ao servidor';
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Tempo de conexao esgotado';
    }

    final data = e.response?.data;

    if (data is List && data.isNotEmpty) {
      final first = data.first;

      if (first is Map && first['mensagem'] != null) {
        return first['mensagem'].toString();
      }

      return first.toString();
    }

    if (data is Map) {
      if (data['mensagem'] != null) {
        return data['mensagem'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    if (e.response?.statusCode != null) {
      return '$fallbackMessage (HTTP ${e.response?.statusCode})';
    }

    return fallbackMessage;
  }

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authDioClient.dio.post(
        Endpoints.authLogin,
        data: {'email': email, 'password': password},
      );

      return AuthTokens(
        token: response.data['token'],
        refreshToken: response.data['refreshToken'],
      );
    } on DioException catch (e) {
      throw AuthException(_mapDioError(e, 'Erro ao fazer login'));
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
      throw AuthException(_mapDioError(e, 'Erro ao cadastrar usuario'));
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
        data: {'token': token, 'refreshToken': refreshToken},
      );

      return AuthTokens(
        token: response.data['token'],
        refreshToken: response.data['refreshToken'],
      );
    } on DioException catch (e) {
      throw AuthException(_mapDioError(e, 'Erro ao atualizar token'));
    }
  }
}
