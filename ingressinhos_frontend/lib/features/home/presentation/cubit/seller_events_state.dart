import 'package:ingressinhos_frontend/core/data/models/event_model.dart';

abstract class SellerEventsState {
  const SellerEventsState();
}

class SellerEventsInitial extends SellerEventsState {
  const SellerEventsInitial();
}

class SellerEventsLoading extends SellerEventsState {
  const SellerEventsLoading();
}

class SellerEventsLoaded extends SellerEventsState {
  final List<EventModel> events;
  final bool hasMore;
  final bool isLoadingMore;

  const SellerEventsLoaded(
    this.events, {
    this.hasMore = true,
    this.isLoadingMore = false,
  });
}

class SellerEventsError extends SellerEventsState {
  final String message;

  const SellerEventsError(this.message);
}
