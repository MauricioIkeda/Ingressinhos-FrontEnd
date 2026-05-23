import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _eventRepository;

  EventsCubit({required EventsRepository eventRepository})
    : _eventRepository = eventRepository,
      super(const EventsInitial());

  Future<void> loadEvents() async {
    emit(const EventsLoading());
    try {
      final List<EventModel> events = await _eventRepository.getEvents();
      emit(EventsLoaded(events));
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> createEvent(EventModel event) async{
    emit (const EventCreating());

    try {
      await _eventRepository.createEvent(event);
      await loadEvents();
      emit(const EventsCreated());
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<List<LocationModel>> loadLocations() async {
    try {
      final locations = await _eventRepository.getAllLocations();
      return locations;
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
      return List<LocationModel>.empty();
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
      return List<LocationModel>.empty();
    }
  }
}