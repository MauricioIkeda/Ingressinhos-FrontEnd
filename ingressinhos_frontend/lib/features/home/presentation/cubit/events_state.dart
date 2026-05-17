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
  final List<dynamic> events;

  const EventsLoaded(this.events);
}

class EventsError extends EventsState {
  final String message;

  const EventsError(this.message);
}