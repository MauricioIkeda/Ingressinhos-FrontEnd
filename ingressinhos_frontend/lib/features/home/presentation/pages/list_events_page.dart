import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/events_state.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/event_details_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/widgets/event_card.dart';

class ListEventPage extends StatefulWidget {
  const ListEventPage({super.key});

  @override
  State<ListEventPage> createState() => _ListEventPageState();
}

class _ListEventPageState extends State<ListEventPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventsCubit>().loadEvents(reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      context.read<EventsCubit>().loadMoreEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventsCubit, EventsState>(
      builder: (context, state) {
        if (state is EventsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is EventsError) {
          return Center(
            child: Text(
              state.message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.redAccent,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        if (state is EventsLoaded) {
          if (state.events.isEmpty) {
            return Center(
              child: Text(
                'Nenhum evento encontrado.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 640;
              final crossAxisCount = isNarrow ? 1 : 2;
              final showLoadingTile = state.isLoadingMore;

              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: EventCard.aspectRatio,
                ),
                itemCount:
                    state.events.length + (showLoadingTile ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= state.events.length) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final event = state.events[index];
                  return EventCard(
                    event: event,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EventDetailsPage(event: event),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        }

        return const Center(child: Text('Nenhum evento encontrado.'));
      },
    );
  }
}
