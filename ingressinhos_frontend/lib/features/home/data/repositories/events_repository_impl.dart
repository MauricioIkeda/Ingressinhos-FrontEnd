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
        event['locationLabel'] = _buildLocationLabel(location, locationId);
        event['locationData'] = location;
      }

      resolvedEvents.add(event);
    }

    return resolvedEvents;
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

  String _buildLocationLabel(Map<String, dynamic> location, int id) {
    final name = location['name']?.toString().trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }

    final address = location['address']?.toString().trim();
    if (address != null && address.isNotEmpty) {
      return address;
    }

    final city = location['city']?.toString().trim();
    if (city != null && city.isNotEmpty) {
      return city;
    }

    return 'Local $id';
  }
}
