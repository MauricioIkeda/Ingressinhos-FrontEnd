import 'dart:convert';

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

  Map<String, dynamic> _parseJwtPayload(String token) {
    final parts = token.split('.');
    if (parts.length != 3) throw FormatException('Token inválido');

    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payloadMap = json.decode(decoded) as Map<String, dynamic>;
    return payloadMap;
  }

  Future<String?> getUserNameFromToken() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final payload = _parseJwtPayload(token);

      return payload['unique_name'] as String;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    await storage.deleteAll();
  }
}
