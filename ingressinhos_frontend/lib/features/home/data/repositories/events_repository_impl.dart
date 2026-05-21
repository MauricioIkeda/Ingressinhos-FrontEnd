import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/data/datasource/ingressinhos_local_datasource.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/events_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDatasource remoteDatasource;

  EventsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<EventModel>> getEvents() async {
    try {
      List<EventModel> eventsData = await remoteDatasource.getEvents();
      for (final event in eventsData) {
        if (event.location != null) {
          final locationId = event.location!.id;
          if (IngressinhosLocalDatasource.locationCache.containsKey(
            locationId,
          )) {
            event.location =
                IngressinhosLocalDatasource.locationCache[locationId];
          } else {
            final location = await remoteDatasource.getLocationById(locationId);
            IngressinhosLocalDatasource.locationCache[locationId] = location;
            event.location = location;
          }
        }
      }

      return eventsData;
    } on Exception catch (e) {
      throw Exception('Erro ao buscar eventos: ${e.toString()}');
    }
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    return await remoteDatasource.getAllLocations();
  }

  @override
  Future<LocationModel> getLocationWithId(int id) async {
    final cached = IngressinhosLocalDatasource.locationCache[id];
    if (cached != null) {
      return cached;
    }

    final location = await remoteDatasource.getLocationById(id);
    IngressinhosLocalDatasource.locationCache[id] = location;
    return location;
  }
}
