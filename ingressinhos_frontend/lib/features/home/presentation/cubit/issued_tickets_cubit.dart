import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/issued_tickets_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/issued_tickets_state.dart';

class IssuedTicketsCubit extends Cubit<IssuedTicketsState> {
  final IssuedTicketsRepository _issuedTicketsRepository;
  static const int _pageSize = 4;
  static const String _orderBy = 'issuedAtUtc desc';
  final List<IssuedTicketModel> _tickets = [];
  int _skip = 0;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  IssuedTicketsCubit({required IssuedTicketsRepository issuedTicketsRepository})
    : _issuedTicketsRepository = issuedTicketsRepository,
      super(const IssuedTicketsInitial());

  String _ticketKey(IssuedTicketModel ticket) {
    final id = ticket.issuedTicketId;
    if (id != null) return 'id:$id';
    return 'access:${ticket.accessCode}';
  }

  int _appendUniqueTickets(List<IssuedTicketModel> tickets) {
    final existingKeys = _tickets.map(_ticketKey).toSet();
    var added = 0;

    for (final ticket in tickets) {
      final key = _ticketKey(ticket);
      if (existingKeys.add(key)) {
        _tickets.add(ticket);
        added++;
      }
    }

    return added;
  }

  Future<void> loadTickets({bool reset = false}) async {
    if (reset) {
      _tickets.clear();
      _skip = 0;
      _hasMore = true;
      _isLoadingMore = false;
    }

    emit(const IssuedTicketsLoading());
    try {
      final tickets = await _issuedTicketsRepository.getIssuedTickets(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
      );
      _tickets.clear();
      _appendUniqueTickets(tickets);
      _skip = _tickets.length;
      _hasMore = tickets.length == _pageSize;
      emit(
        IssuedTicketsLoaded(
          List<IssuedTicketModel>.from(_tickets),
          hasMore: _hasMore,
        ),
      );
    } on IngressinhosException catch (e) {
      emit(IssuedTicketsError(e.message));
    } catch (e) {
      emit(IssuedTicketsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreTickets() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    emit(
      IssuedTicketsLoaded(
        List<IssuedTicketModel>.from(_tickets),
        hasMore: _hasMore,
        isLoadingMore: true,
      ),
    );

    try {
      final tickets = await _issuedTicketsRepository.getIssuedTickets(
        skip: _skip,
        top: _pageSize,
        orderBy: _orderBy,
      );
      final added = _appendUniqueTickets(tickets);
      _skip = _tickets.length;
      _hasMore = tickets.length == _pageSize && added > 0;
    } catch (_) {
      _isLoadingMore = false;
      emit(
        IssuedTicketsLoaded(
          List<IssuedTicketModel>.from(_tickets),
          hasMore: _hasMore,
          isLoadingMore: false,
        ),
      );
      return;
    }

    _isLoadingMore = false;
    emit(
      IssuedTicketsLoaded(
        List<IssuedTicketModel>.from(_tickets),
        hasMore: _hasMore,
        isLoadingMore: false,
      ),
    );
  }
}
