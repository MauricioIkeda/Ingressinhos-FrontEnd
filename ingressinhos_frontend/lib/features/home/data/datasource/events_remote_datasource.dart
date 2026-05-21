import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';

abstract class EventsRemoteDatasource{
  Future<List<EventModel>> getEvents();
  Future<LocationModel> getLocationById(int id);
  Future<List<LocationModel>> getAllLocations();
}