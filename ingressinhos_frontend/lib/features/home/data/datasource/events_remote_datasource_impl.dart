import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/events_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';

class EventsRemoteDatasourceImpl implements EventsRemoteDatasource {
  final IngressinhosDioClient _ingressinhosClient;

  EventsRemoteDatasourceImpl(this._ingressinhosClient);

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _ingressinhosClient.dio.get(Endpoints.eventos, queryParameters: {r'$top': 10});

      List<EventModel> events = [];

      for (var item in response.data['data']) {
        EventModel event = EventModel.fromJson(item);
        final ticket = await _ingressinhosClient.dio.get(Endpoints.tickets, queryParameters: {'eventId': event.id, r'$top': 1});
        if (ticket.data['data'].isNotEmpty) {
          event.baseTicketPrice = ticket.data['data'][0]['basePrice'];
        }

        if (event.locationId != null) {
          final location = await _ingressinhosClient.dio.get(Endpoints.locations, queryParameters: {'id': event.locationId});
          event.locationName = location.data['data'][0]['name'];
        }
        events.add(event);
      }

      return events;
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
      await _ingressinhosClient.dio.post(Endpoints.eventos, data: eventModel.toJson());
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao criar evento'));
    }
  }
}
