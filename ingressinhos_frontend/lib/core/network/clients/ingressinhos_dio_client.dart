import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';

class IngressinhosDioClient {
  final Dio dio;

  IngressinhosDioClient(SecureStorageService storage)
    : dio = Dio(
        BaseOptions(
          baseUrl: Endpoints.ingressinhosBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await storage.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
      ),
    );
  }
}
