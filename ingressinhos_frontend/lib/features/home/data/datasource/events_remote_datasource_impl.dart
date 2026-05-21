import 'package:dio/dio.dart';
import 'package:ingressinhos_frontend/core/data/datasource/ingressinhos_local_datasource.dart';
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
        events.add(event);
      }

      return events;
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar eventos'));
    }
  }

  @override
  Future<LocationModel> getLocationById(int id) async {
    try {
      final response = await _ingressinhosClient.dio.get(
        '${Endpoints.locations}/$id',
      );

      LocationModel location = LocationModel.fromJson(response.data['data']);

      IngressinhosLocalDatasource.locationCache[id] = location;
      return location;
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar localização'));
    }
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    try {
      final response = await _ingressinhosClient.dio.get(Endpoints.locations);
      List<LocationModel> locations = (response.data['data'] as List)
          .map((e) => LocationModel.fromJson(e))
          .toList();

      IngressinhosLocalDatasource.locationCache.clear();

      for (final location in locations) {
        IngressinhosLocalDatasource.locationCache[location.id] = location;
      }

      return locations;
    } on DioException catch (e) {
      throw IngressinhosException(mapDioError(e, 'Erro ao buscar localizações'));
    }
  }
}
