import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/ingressinhos_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';

class IngressinhosRemoteDatasourceImpl implements IngressinhosRemoteDatasource {
  final IngressinhosDioClient _ingressinhosClient;

  IngressinhosRemoteDatasourceImpl(this._ingressinhosClient);

  @override
  Future<List<dynamic>> getEvents() async {
    try {
      final response = await _ingressinhosClient.dio.get(Endpoints.eventos);

      return response.data['data'];
    } on DioException catch (e) {
      print("erro");
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar eventos'));
    }
  }

  @override
  Future<Map<String, dynamic>> getLocationById(int id) async {
    try {
      final response = await _ingressinhosClient.dio.get(
        '${Endpoints.locations}/$id',
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is Map<String, dynamic>) {
          return payload;
        }

        return data;
      }

      if (data is Map) {
        final mapData = Map<String, dynamic>.from(data);
        final payload = mapData['data'];
        if (payload is Map<String, dynamic>) {
          return payload;
        }

        return mapData;
      }

      throw IngressinhosException('Resposta de localização inválida');
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar localização'));
    }
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    try {
      final response = await _ingressinhosClient.dio.get(Endpoints.locations);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final payload = data['data'];
        if (payload is List) {
          final teste = payload
              .whereType<Map<String, dynamic>>()
              .map((json) => LocationModel.fromJson(json))
              .toList();
          return teste;
        }
      }

      throw IngressinhosException('Resposta de localizações inválida');
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar localizações'));
    }
  }
}
