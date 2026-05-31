import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/seller_events_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/seller_events_state.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/edit_event_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/widgets/event_card.dart';

class SellerEventsPage extends StatefulWidget {
  const SellerEventsPage({super.key});

  @override
  State<SellerEventsPage> createState() => _SellerEventsPageState();
}

class _SellerEventsPageState extends State<SellerEventsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellerEventsCubit>().loadEvents(reset: true);
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
      context.read<SellerEventsCubit>().loadMoreEvents();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const IngressinhosAppBar(
        title: 'Meus eventos',
        titleFontSize: 22,
        showCartAction: false,
      ),
      body: BlocBuilder<SellerEventsCubit, SellerEventsState>(
        builder: (context, state) {
          if (state is SellerEventsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is SellerEventsError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => context
                          .read<SellerEventsCubit>()
                          .loadEvents(reset: true),
                      icon: const Icon(Icons.refresh),
                      label: Text(
                        'Tentar novamente',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is SellerEventsLoaded) {
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
                  itemCount: state.events.length + (showLoadingTile ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.events.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    final event = state.events[index];
                    return EventCard(
                      event: event,
                      onTap: () async {
                        final changed = await Navigator.of(context).push<bool>(
                          MaterialPageRoute(
                            builder: (_) => EditEventPage(event: event),
                          ),
                        );
                        if (!context.mounted || changed != true) return;
                        context.read<SellerEventsCubit>().loadEvents(
                          reset: true,
                        );
                      },
                    );
                  },
                );
              },
            );
          }

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
        },
      ),
    );
  }
}
