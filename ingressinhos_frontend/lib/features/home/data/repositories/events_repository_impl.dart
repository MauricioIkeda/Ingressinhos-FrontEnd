import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/home/data/datasource/events_remote_datasource.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';

class EventsRepositoryImpl implements EventsRepository {
  final EventsRemoteDatasource remoteDatasource;
  final storage = getIt<SecureStorageService>();

  EventsRepositoryImpl({required this.remoteDatasource});

  @override
  Future<List<EventModel>> getEvents({
    int skip = 0,
    int top = 4,
    String orderBy = 'startTime asc',
    int? sellerId,
  }) async {
    try {
      List<EventModel> eventsData = await remoteDatasource.getEvents(
        skip: skip,
        top: top,
        orderBy: orderBy,
        sellerId: sellerId,
      );

      return eventsData;
    } on Exception catch (e) {
      throw Exception('Erro ao buscar eventos: ${e.toString()}');
    }
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    try {
      List<LocationModel> locationsData = await remoteDatasource
          .getAllLocations();

      return locationsData;
    } on Exception catch (e) {
      throw Exception('Erro ao buscar locais: ${e.toString()}');
    }
  }

  @override
  Future<int> getCurrentSellerId() async {
    try {
      return await remoteDatasource.getCurrentSellerId();
    } on Exception catch (e) {
      throw Exception('Erro ao buscar vendedor: ${e.toString()}');
    }
  }

  @override
  Future<void> createEvent(EventModel eventModel) async {
    try {
      await storage.getUserFromToken();

      await remoteDatasource.createEvent(eventModel);
    } on Exception catch (e) {
      throw Exception('Erro ao criar evento: ${e.toString()}');
    }
  }

  @override
  Future<void> updateEvent(int eventId, EventModel eventModel) async {
    try {
      await remoteDatasource.updateEvent(eventId, eventModel);
    } on Exception catch (e) {
      throw Exception('Erro ao atualizar evento: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteEvent(int eventId) async {
    try {
      await remoteDatasource.deleteEvent(eventId);
    } on Exception catch (e) {
      throw Exception('Erro ao apagar evento: ${e.toString()}');
    }
  }
}
