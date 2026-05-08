import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final storage = const FlutterSecureStorage();

  Future<void> saveToken({
    required String token,
    required String refreshToken,
  }) async {
    await storage.write(key: "token", value: token);

    await storage.write(key: "refresh_token", value: refreshToken);
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: "refresh_token");
  }

  Future<void> clearTokens() async {
    await storage.deleteAll();
  }
}
