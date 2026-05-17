import 'package:dio/dio.dart';

String mapDioError(DioException e, String fallbackMessage) {
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
