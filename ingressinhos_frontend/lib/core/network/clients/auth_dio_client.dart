import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';

class AuthDioClient {
  final Dio dio;

  AuthDioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.authBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
}
