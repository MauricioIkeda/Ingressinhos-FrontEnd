import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/issued_tickets_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/issued_tickets_state.dart';
import 'package:ingressinhos_frontend/features/home/presentation/widgets/issued_ticket_card.dart';

class MyTicketsPage extends StatefulWidget {
  const MyTicketsPage({super.key});

  @override
  State<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends State<MyTicketsPage> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IssuedTicketsCubit>().loadTickets(reset: true);
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
      context.read<IssuedTicketsCubit>().loadMoreTickets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const IngressinhosAppBar(
        title: 'Meus ingressos',
        titleFontSize: 22,
        showCartAction: false,
      ),
      body: BlocBuilder<IssuedTicketsCubit, IssuedTicketsState>(
        builder: (context, state) {
          if (state is IssuedTicketsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          if (state is IssuedTicketsError) {
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
                      onPressed: () =>
                          context.read<IssuedTicketsCubit>().loadTickets(
                            reset: true,
                          ),
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

          if (state is IssuedTicketsLoaded) {
            if (state.tickets.isEmpty) {
              return Center(
                child: Text(
                  'Nenhum ingresso encontrado.',
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
                    childAspectRatio: IssuedTicketCard.aspectRatio,
                  ),
                  itemCount: state.tickets.length + (showLoadingTile ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= state.tickets.length) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      );
                    }
                    final ticket = state.tickets[index];
                    return IssuedTicketCard(ticket: ticket);
                  },
                );
              },
            );
          }

          return Center(
            child: Text(
              'Nenhum ingresso encontrado.',
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
