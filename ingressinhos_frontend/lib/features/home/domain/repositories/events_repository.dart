abstract class EventsRepository {
  Future<List<dynamic>> getEvents();
  Future<List<dynamic>> getEventsWithLocations();
}
