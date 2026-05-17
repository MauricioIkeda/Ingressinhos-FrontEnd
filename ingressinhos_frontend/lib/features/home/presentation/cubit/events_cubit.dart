import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/domain/repositories/events_repository.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventsRepository _repository;

  EventsCubit({required EventsRepository repository})
    : _repository = repository,
      super(const EventsInitial());

  Future<void> loadEvents() async {
    emit(const EventsLoading());

    try {
      final events = await _repository.getEventsWithLocations();
      emit(EventsLoaded(events));
    } on IngressinhosException catch (e) {
      emit(EventsError(e.message));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
