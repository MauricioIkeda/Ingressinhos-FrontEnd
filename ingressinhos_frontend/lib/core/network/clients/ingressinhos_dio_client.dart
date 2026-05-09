import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';

class IngressinhosDioClient {
  final Dio dio;

  IngressinhosDioClient()
    : dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.ingressinhosBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
}
