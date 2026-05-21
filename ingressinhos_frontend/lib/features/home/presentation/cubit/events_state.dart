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

  const EventsLoaded(this.events);
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);
}

class EventCreating extends EventsState {
  const EventCreating();
}