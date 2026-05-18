import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/ingressinhos_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final IngressinhosRemoteDatasource remoteDatasource;
  final Map<int, Map<String, dynamic>> _locationCache = {};

  EventsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<dynamic>> getEvents() async {
    return await remoteDatasource.getEvents();
  }

  @override
  Future<List<dynamic>> getEventsWithLocations() async {
    final events = await getEvents();

    final resolvedEvents = <dynamic>[];

    for (final rawEvent in events) {
      if (rawEvent is! Map) {
        resolvedEvents.add(rawEvent);
        continue;
      }

      final event = Map<String, dynamic>.from(rawEvent);
      final locationId = event['locationId'];

      if (locationId is int) {
        final location = await _getLocation(locationId);
        event['locationLabel'] = location['name']?.toString().trim();
        event['locationData'] = location;
      }

      resolvedEvents.add(event);
    }

    return resolvedEvents;
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    return await remoteDatasource.getAllLocations();
  }

  Future<Map<String, dynamic>> _getLocation(int id) async {
    final cached = _locationCache[id];
    if (cached != null) {
      return cached;
    }

    final location = await remoteDatasource.getLocationById(id);
    _locationCache[id] = location;
    return location;
  }
}
