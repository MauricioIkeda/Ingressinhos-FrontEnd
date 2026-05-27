import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/issued_tickets_remote_datasource.dart';

class IssuedTicketsRemoteDatasourceImpl
    implements IssuedTicketsRemoteDatasource {
  final IngressinhosDioClient _ingressinhosClient;

  IssuedTicketsRemoteDatasourceImpl(this._ingressinhosClient);

  @override
  Future<List<IssuedTicketModel>> getIssuedTickets({
    int skip = 0,
    int top = 4,
    String? orderBy,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        r'$top': top,
        r'$skip': skip,
      };
      if (orderBy != null && orderBy.trim().isNotEmpty) {
        queryParameters[r'$orderby'] = orderBy;
      }

      final response = await _ingressinhosClient.dio.get(
        Endpoints.issuedTicketsMe,
        queryParameters: queryParameters,
      );

      final data = response.data;
      final List<dynamic> items;
      if (data is Map && data['data'] is List) {
        items = data['data'] as List;
      } else if (data is List) {
        items = data;
      } else {
        items = [];
      }

      return items
          .whereType<Map<String, dynamic>>()
          .map(IssuedTicketModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw IngressinhosException(
        mapDioError(e, 'Erro ao buscar ingressos emitidos'),
      );
    }
  }
}
