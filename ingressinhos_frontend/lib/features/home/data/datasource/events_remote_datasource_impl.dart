import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/data/models/ticket_model.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/events_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';

class EventsRemoteDatasourceImpl implements EventsRemoteDatasource {
  final IngressinhosDioClient _ingressinhosClient;

  EventsRemoteDatasourceImpl(this._ingressinhosClient);

  @override
  Future<List<EventModel>> getEvents({
    int skip = 0,
    int top = 4,
    String orderBy = 'startTime asc',
  }) async {
    try {
      final response = await _ingressinhosClient.dio.get(
        Endpoints.eventsWithTickets,
        queryParameters: {
          r'$top': top,
          r'$skip': skip,
          r'$orderby': orderBy,
        },
      );

      final data = response.data['data'] as List? ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(EventModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar eventos'));
    }
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    final response = await _ingressinhosClient.dio.get(Endpoints.locations);
    return (response.data['data'] as List)
        .map((json) => LocationModel.fromJson(json))
        .toList();
  }

@override
  Future<void> createEvent(EventModel eventModel) async {
    try {
      final response = await _ingressinhosClient.dio.post(Endpoints.eventos, data: eventModel.toJson());

      TicketModel ticket = TicketModel(
        eventId: response.data['eventId'].toInt(),
        ticketId: 0,
        name: '${eventModel.name} - Ingresso',
        basePrice: eventModel.baseTicketPrice!,
        premiumPrice: eventModel.premiumTicketPrice ?? 0,
        vipPrice: eventModel.vipTicketPrice ?? 0,
        salesStartsAt: eventModel.salesStartsAt!,
        salesEndsAt: eventModel.salesEndsAt!,
        isActive: eventModel.isActive ?? true,
      );

      await _ingressinhosClient.dio.post(Endpoints.tickets, data: ticket.toJson());

    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao criar evento'));
    } catch (e) {
      throw IngressinhosException('Erro do front burro cansado por algum motivo: ${e.toString()}');
    }
  }
}
