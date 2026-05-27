import 'package:ingressinhos_frontend/core/data/models/event_model.dart';

abstract class EventsState {
  const EventsState();
}

class EventsInitial extends EventsState {
  const EventsInitial();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

class EventsLoaded extends EventsState {
  final List<EventModel> events;
  final bool hasMore;
  final bool isLoadingMore;

  const EventsLoaded(
    this.events, {
    this.hasMore = true,
    this.isLoadingMore = false,
  });
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);
}

class EventsCreated extends EventsState {
  const EventsCreated();
}

class EventCreating extends EventsState {
  const EventCreating();
}

class EventUpdating extends EventsState {
  const EventUpdating();
}

class EventsUpdated extends EventsState {
  const EventsUpdated();
}

class EventDeleting extends EventsState {
  const EventDeleting();
}

class EventsDeleted extends EventsState {
  const EventsDeleted();
}
