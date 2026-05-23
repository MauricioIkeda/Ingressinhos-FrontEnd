import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _eventRepository;
  static const int _pageSize = 4;
  static const String _orderBy = 'startTime asc';
  final List<EventModel> _events = [];
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  EventsCubit({required EventsRepository eventRepository})
    : _eventRepository = eventRepository,
      super(const EventsInitial());

  Future<void> loadEvents({bool reset = false}) async {
    if (reset) {
      _events.clear();
      _skip = 0;
      _hasMore = true;
      _isLoadingMore = false;
    }
    emit(const EventsLoading());
    try {
      final List<EventModel> events = await _eventRepository.getEvents(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
      );
      _events
        ..clear()
        ..addAll(events);
      _skip = _events.length;
      _hasMore = events.length == _pageSize;
      emit(EventsLoaded(
        List<EventModel>.from(_events),
        hasMore: _hasMore,
      ));
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    emit(EventsLoaded(
      List<EventModel>.from(_events),
      hasMore: _hasMore,
      isLoadingMore: true,
    ));

    try {
      final List<EventModel> events = await _eventRepository.getEvents(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
      );
      _events.addAll(events);
      _skip = _events.length;
      _hasMore = events.length == _pageSize;
    } catch (_) {
      _isLoadingMore = false;
      emit(EventsLoaded(
        List<EventModel>.from(_events),
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
      return;
    }

    _isLoadingMore = false;
    emit(EventsLoaded(
      List<EventModel>.from(_events),
      hasMore: _hasMore,
      isLoadingMore: false,
    ));
  }

  Future<void> createEvent(EventModel event) async{
    emit (const EventCreating());

    try {
      await _eventRepository.createEvent(event);
      await loadEvents(reset: true);
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
