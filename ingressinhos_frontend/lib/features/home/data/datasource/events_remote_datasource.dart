import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';

abstract class EventsRemoteDatasource{
  Future<List<EventModel>> getEvents({
    int skip = 0,
    int top = 4,
    String orderBy = 'startTime asc',
  });
  Future<List<LocationModel>> getAllLocations();
  
  Future<void> createEvent(EventModel eventModel);
}
