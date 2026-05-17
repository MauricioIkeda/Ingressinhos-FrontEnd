abstract class IngressinhosRemoteDatasource{
  Future<List<dynamic>> getEvents();
  Future<Map<String, dynamic>> getLocationById(int id);
}