import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/data/models/location_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _eventRepository;
  static const int _pageSize = 6;
  static const String _orderBy = 'startTime asc';
  static const Duration _cacheDuration = Duration(minutes: 2);
  final List<EventModel> _events = [];
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  DateTime? _lastLoadedAt;

  EventsCubit({required EventsRepository eventRepository})
    : _eventRepository = eventRepository,
      super(const EventsInitial());

  bool get _hasValidCache {
    final lastLoadedAt = _lastLoadedAt;
    if (_events.isEmpty || lastLoadedAt == null) return false;
    return DateTime.now().difference(lastLoadedAt) < _cacheDuration;
  }

  String _eventKey(EventModel event) {
    final id = event.id;
    if (id != null) return 'id:$id';
    return '${event.name}:${event.startTime.toIso8601String()}';
  }

  int _appendUniqueEvents(List<EventModel> events) {
    final existingKeys = _events.map(_eventKey).toSet();
    var added = 0;

    for (final event in events) {
      final key = _eventKey(event);
      if (existingKeys.add(key)) {
        _events.add(event);
        added++;
      }
    }

    return added;
  }

  Future<void> loadEvents({
    bool reset = false,
    bool forceRefresh = false,
  }) async {
    if (reset && !forceRefresh && _hasValidCache) {
      emit(
        EventsLoaded(
          List<EventModel>.from(_events),
          hasMore: _hasMore,
          isLoadingMore: false,
        ),
      );
      return;
    }

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
      _events.clear();
      _appendUniqueEvents(events);
      _skip = _events.length;
      _hasMore = events.length == _pageSize;
      _lastLoadedAt = DateTime.now();
      emit(EventsLoaded(List<EventModel>.from(_events), hasMore: _hasMore));
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    emit(
      EventsLoaded(
        List<EventModel>.from(_events),
        hasMore: _hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final List<EventModel> events = await _eventRepository.getEvents(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
      );
      final added = _appendUniqueEvents(events);
      _skip = _events.length;
      _hasMore = events.length == _pageSize && added > 0;
      _lastLoadedAt = DateTime.now();
    } catch (_) {
      _isLoadingMore = false;
      emit(
        EventsLoaded(
          List<EventModel>.from(_events),
          hasMore: _hasMore,
          isLoadingMore: false,
        ),
      );
      return;
    }

    _isLoadingMore = false;
    emit(
      EventsLoaded(
        List<EventModel>.from(_events),
        hasMore: _hasMore,
        isLoadingMore: false,
      ),
    );
  }

  Future<void> createEvent(EventModel event) async {
    emit(const EventCreating());

    try {
      await _eventRepository.createEvent(event);
      await loadEvents(reset: true, forceRefresh: true);
      emit(const EventsCreated());
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> updateEvent(int eventId, EventModel event) async {
    emit(const EventUpdating());

    try {
      await _eventRepository.updateEvent(eventId, event);
      await loadEvents(reset: true, forceRefresh: true);
      emit(const EventsUpdated());
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> deleteEvent(int eventId) async {
    emit(const EventDeleting());

    try {
      await _eventRepository.deleteEvent(eventId);
      await loadEvents(reset: true, forceRefresh: true);
      emit(const EventsDeleted());
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
