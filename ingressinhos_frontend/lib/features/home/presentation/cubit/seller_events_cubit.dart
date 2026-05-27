import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/seller_events_state.dart';

class SellerEventsCubit extends Cubit<SellerEventsState> {
  final EventsRepository _eventRepository;
  final SecureStorageService _storage;
  static const int _pageSize = 4;
  static const String _orderBy = 'startTime desc';
  final List<EventModel> _events = [];
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  SellerEventsCubit({
    required EventsRepository eventRepository,
    required SecureStorageService storage,
  })  : _eventRepository = eventRepository,
        _storage = storage,
        super(const SellerEventsInitial());

  Future<int?> _loadSellerId() async {
    final user = await _storage.getUserFromToken();
    return user.sellerId;
  }

  Future<void> loadEvents({bool reset = false}) async {
    if (reset) {
      _events.clear();
      _skip = 0;
      _hasMore = true;
      _isLoadingMore = false;
    }

    emit(const SellerEventsLoading());
    try {
      final sellerId = await _loadSellerId();
      if (sellerId == null) {
        emit(const SellerEventsError('Seller nao encontrado no token'));
        return;
      }

      final List<EventModel> events = await _eventRepository.getEvents(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
        sellerId: sellerId,
      );

      _events
        ..clear()
        ..addAll(events);
      _skip = _events.length;
      _hasMore = events.length == _pageSize;
      emit(SellerEventsLoaded(
        List<EventModel>.from(_events),
        hasMore: _hasMore,
      ));
    } on IngressinhosException catch (e) {
      emit(SellerEventsError(e.message));
    } catch (e) {
      emit(SellerEventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreEvents() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    emit(SellerEventsLoaded(
      List<EventModel>.from(_events),
      hasMore: _hasMore,
      isLoadingMore: true,
    ));

    try {
      final sellerId = await _loadSellerId();
      if (sellerId == null) {
        _isLoadingMore = false;
        emit(const SellerEventsError('Seller nao encontrado no token'));
        return;
      }

      final List<EventModel> events = await _eventRepository.getEvents(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
        sellerId: sellerId,
      );
      _events.addAll(events);
      _skip = _events.length;
      _hasMore = events.length == _pageSize;
    } catch (_) {
      _isLoadingMore = false;
      emit(SellerEventsLoaded(
        List<EventModel>.from(_events),
        hasMore: _hasMore,
        isLoadingMore: false,
      ));
      return;
    }

    _isLoadingMore = false;
    emit(SellerEventsLoaded(
      List<EventModel>.from(_events),
      hasMore: _hasMore,
      isLoadingMore: false,
    ));
  }
}
