import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ingressinhos_frontend/core/data/models/user_model.dart';

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
    return json.decode(decoded) as Map<String, dynamic>;
  }

  Future<UserModel> getUserFromToken() async {
    final token = await getToken();
    if (token == null) throw Exception('Token não encontrado');

    try {
      final payload = _parseJwtPayload(token);

      final sellerId = payload['sellerId'] as int?;
      final name = payload['unique_name'] as String?;
      final role = payload['role'] as String?;

      if (name == null || role == null) throw Exception('Dados do usuário inválidos');

      return UserModel(name: name, role: role, sellerId: sellerId);
    } catch (_) {
      throw Exception('Erro ao processar token');
    }
  }

  Future<void> clearTokens() async {
    await storage.deleteAll();
  }
}
