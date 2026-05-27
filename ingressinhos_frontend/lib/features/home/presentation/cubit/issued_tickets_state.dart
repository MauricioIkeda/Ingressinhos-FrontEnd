import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';

abstract class IssuedTicketsState {
  const IssuedTicketsState();
}

class IssuedTicketsInitial extends IssuedTicketsState {
  const IssuedTicketsInitial();
}

class IssuedTicketsLoading extends IssuedTicketsState {
  const IssuedTicketsLoading();
}

class IssuedTicketsLoaded extends IssuedTicketsState {
  final List<IssuedTicketModel> tickets;
  final bool hasMore;
  final bool isLoadingMore;

  const IssuedTicketsLoaded(
    this.tickets, {
    this.hasMore = true,
    this.isLoadingMore = false,
  });
}

class IssuedTicketsError extends IssuedTicketsState {
  final String message;

  const IssuedTicketsError(this.message);
}
