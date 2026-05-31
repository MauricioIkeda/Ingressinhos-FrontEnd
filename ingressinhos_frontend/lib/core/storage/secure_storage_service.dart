import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ingressinhos_frontend/core/data/models/user_model.dart';

class SecureStorageService {
  final storage = const FlutterSecureStorage();
  static const _oauthStateKey = 'oauth_state';

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

  Future<void> saveOAuthState(String state) async {
    await storage.write(key: _oauthStateKey, value: state);
  }

  Future<String?> getOAuthState() async {
    return await storage.read(key: _oauthStateKey);
  }

  Future<void> clearOAuthState() async {
    await storage.delete(key: _oauthStateKey);
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

      final sellerIdClaim = payload['sellerId'];
      final sellerId = sellerIdClaim is num ? sellerIdClaim.toInt() : null;
      final name = (payload['name'] ?? payload['unique_name']) as String?;
      final roleClaim =
          payload['role'] ??
          payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'];
      final role = roleClaim is List
          ? (roleClaim.isEmpty ? null : roleClaim.first.toString())
          : roleClaim?.toString();

      if (name == null) {
        throw Exception('Dados do usuário inválidos');
      }

      return UserModel(name: name, role: role ?? '', sellerId: sellerId);
    } catch (_) {
      throw Exception('Erro ao processar token');
    }
  }

  Future<({String? name, String? email})> getIdentityFromToken() async {
    final token = await getToken();
    if (token == null) {
      return (name: null, email: null);
    }

    final payload = _parseJwtPayload(token);
    final name = (payload['name'] ?? payload['unique_name'])?.toString();
    final email =
        (payload['email'] ??
                payload['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'])
            ?.toString();

    return (name: name, email: email);
  }

  Future<void> clearTokens() async {
    await storage.deleteAll();
  }
}
