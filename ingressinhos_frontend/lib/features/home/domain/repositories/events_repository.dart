import 'package:ingressinhos_frontend/core/data/models/location_model.dart';

abstract class EventsRepository {
  Future<List<dynamic>> getEvents();
  Future<List<dynamic>> getEventsWithLocations();
  Future<List<LocationModel>> getAllLocations();
}
