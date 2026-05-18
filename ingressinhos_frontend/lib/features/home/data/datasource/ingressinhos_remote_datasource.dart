import 'package:ingressinhos_frontend/core/data/models/location_model.dart';

abstract class IngressinhosRemoteDatasource{
  Future<List<dynamic>> getEvents();
  Future<Map<String, dynamic>> getLocationById(int id);
  Future<List<LocationModel>> getAllLocations();
}