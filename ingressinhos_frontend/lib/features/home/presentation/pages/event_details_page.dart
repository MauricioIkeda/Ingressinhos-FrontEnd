import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/ingressinhos_exception.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/cart_cubit.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  int _baseQuantity = 0;
  int _premiumQuantity = 0;
  int _vipQuantity = 0;

  int get _totalTickets => _baseQuantity + _premiumQuantity + _vipQuantity;

  double get _totalPrice {
    final event = widget.event;
    return (_baseQuantity * (event.baseTicketPrice ?? 0)) +
        (_premiumQuantity * (event.premiumTicketPrice ?? 0)) +
        (_vipQuantity * (event.vipTicketPrice ?? 0));
  }

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $formatted';
  }

  void _incrementQuantity(TicketType type) {
    setState(() {
      switch (type) {
        case TicketType.base:
          _baseQuantity++;
          break;
        case TicketType.premium:
          _premiumQuantity++;
          break;
        case TicketType.vip:
          _vipQuantity++;
          break;
      }
    });
  }

  void _decrementQuantity(TicketType type) {
    setState(() {
      switch (type) {
        case TicketType.base:
          if (_baseQuantity > 0) _baseQuantity--;
          break;
        case TicketType.premium:
          if (_premiumQuantity > 0) _premiumQuantity--;
          break;
        case TicketType.vip:
          if (_vipQuantity > 0) _vipQuantity--;
          break;
      }
    });
  }

  void _onBuyPressed() {
    if (_totalTickets <= 0) return;

    final summary = <String>[];
    if (_baseQuantity > 0) summary.add('Base: $_baseQuantity');
    if (_premiumQuantity > 0) summary.add('Premium: $_premiumQuantity');
    if (_vipQuantity > 0) summary.add('VIP: $_vipQuantity');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Compra iniciada (${summary.join(' • ')}) • Total: ${_formatCurrency(_totalPrice)}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Future<void> _onAddToCart() async {
    if (_totalTickets <= 0) return;

    try {
      await context.read<CartCubit>().addTickets(
            event: widget.event,
            baseQuantity: _baseQuantity,
            premiumQuantity: _premiumQuantity,
            vipQuantity: _vipQuantity,
          );
    } on IngressinhosException catch (e) {
      if (!mounted) return;
      showErrorSnackBar(context, e.message, true);
      return;
    } catch (e) {
      if (!mounted) return;
      showErrorSnackBar(
        context,
        e.toString().replaceFirst('Exception: ', ''),
        true,
      );
      return;
    }

    if (!mounted) return;

    final summary = <String>[];
    if (_baseQuantity > 0) summary.add('Base: $_baseQuantity');
    if (_premiumQuantity > 0) summary.add('Premium: $_premiumQuantity');
    if (_vipQuantity > 0) summary.add('VIP: $_vipQuantity');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ingressos adicionados ao carrinho (${summary.join(' • ')}) • Total: ${_formatCurrency(_totalPrice)}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final availableTickets = event.availableTickets ?? 0;
    final hasAvailableTickets = availableTickets > 0;
    final title = event.name.trim().isNotEmpty ? event.name : 'Evento sem nome';
    final description = (event.description?.trim().isNotEmpty == true)
        ? event.description!
        : 'Sem descrição disponível para este evento.';
    final locationLabel = event.locationName?.trim().isNotEmpty == true
        ? event.locationName!
        : 'Local não informado';
    final startText = _formatDateTime(event.startTime);
    final endText = _formatDateTime(event.endTime);
    final sellerName = (event.sellerTradingName?.trim().isNotEmpty == true)
        ? event.sellerTradingName!.trim()
        : 'Vendedor desconhecido';
    final availableTicketsText = event.availableTickets != null
        ? '${event.availableTickets} ingresso(s) disponíveis'
        : 'Quantidade de ingressos disponível não informada';

    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const IngressinhosAppBar(
        title: 'Detalhes do evento',
        titleFontSize: 22,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: _EventHeaderImage(imageUrl: event.imageUrl),
                  ),
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StatusBadge(isAvailable: event.hasSeats),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Informações',
              child: Column(
                children: [
                  _InfoTile(
                    icon: Icons.calendar_month_rounded,
                    label: 'Início',
                    value: startText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.event_available_rounded,
                    label: 'Término',
                    value: endText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.location_on_rounded,
                    label: 'Local',
                    value: locationLabel,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.event_seat_rounded,
                    label: 'Assentos',
                    value: event.hasSeats ? 'Disponível' : 'Indisponível',
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.confirmation_num_rounded,
                    label: 'Ingressos disponíveis',
                    value: availableTicketsText,
                  ),
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.storefront_rounded,
                    label: 'Vendedor',
                    value: sellerName,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: 'Descrição',
              child: Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 14.5,
                  height: 1.65,
                  color: AppColors.primaryText,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _InfoCard(
              title: 'Ingressos',
              child: Column(
                children: [
                  _TicketTypeSelector(
                    label: 'Base',
                    price:
                        event.baseTicketPrice == 0.0 ||
                            event.baseTicketPrice == null
                        ? 'Gratis'
                        : _formatCurrency(event.baseTicketPrice!),
                    quantity: _baseQuantity,
                    canIncrement:
                        hasAvailableTickets && _totalTickets < availableTickets,
                    onIncrement: () => _incrementQuantity(TicketType.base),
                    onDecrement: () => _decrementQuantity(TicketType.base),
                  ),
                  if (event.premiumTicketPrice != null &&
                      event.premiumTicketPrice! > 0.0) ...[
                    const SizedBox(height: 12),
                    _TicketTypeSelector(
                      label: 'Premium',
                      price: _formatCurrency(event.premiumTicketPrice!),
                      quantity: _premiumQuantity,
                      canIncrement:
                          hasAvailableTickets &&
                          _totalTickets < availableTickets,
                      onIncrement: () => _incrementQuantity(TicketType.premium),
                      onDecrement: () => _decrementQuantity(TicketType.premium),
                    ),
                  ],
                  if (event.vipTicketPrice != null &&
                      event.vipTicketPrice! > 0.0) ...[
                    const SizedBox(height: 12),
                    _TicketTypeSelector(
                      label: 'VIP',
                      price: _formatCurrency(event.vipTicketPrice!),
                      quantity: _vipQuantity,
                      canIncrement:
                          hasAvailableTickets &&
                          _totalTickets < availableTickets,
                      onIncrement: () => _incrementQuantity(TicketType.vip),
                      onDecrement: () => _decrementQuantity(TicketType.vip),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.primaryColor.withValues(alpha: 0.24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.shopping_bag_rounded,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$_totalTickets ingresso(s) • Total: ${_formatCurrency(_totalPrice)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _totalTickets > 0 ? _onBuyPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _totalTickets > 0
                      ? 'Comprar $_totalTickets ingresso(s)'
                      : 'Selecione os ingressos',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _totalTickets > 0 ? _onAddToCart : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  _totalTickets > 0
                      ? 'Adicionar $_totalTickets ingresso(s) ao carrinho'
                      : 'Selecione os ingressos',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }
}

enum TicketType { base, premium, vip }

class _EventHeaderImage extends StatelessWidget {
  final String? imageUrl;

  const _EventHeaderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.trim().isEmpty) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primaryColor, AppColors.accentSecondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Icon(Icons.event_rounded, color: Colors.white, size: 90),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(
            Icons.broken_image_rounded,
            size: 64,
            color: Colors.white70,
          ),
        ),
      ),
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.black12,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isAvailable;

  const _StatusBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable
        ? const Color(0xFF22C55E)
        : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        isAvailable ? 'COM VAGAS' : 'LOTADO',
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.7,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketTypeSelector extends StatelessWidget {
  final String label;
  final String? price;
  final int quantity;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _TicketTypeSelector({
    required this.label,
    required this.price,
    required this.quantity,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isAvailable = price != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAvailable
              ? AppColors.primaryColor.withValues(alpha: 0.22)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingresso $label',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isAvailable ? price! : 'Indisponível',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: isAvailable && quantity > 0 ? onDecrement : null,
                icon: const Icon(Icons.remove_circle_outline_rounded),
                color: AppColors.primaryColor,
              ),
              SizedBox(
                width: 28,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              if (isAvailable && canIncrement)
                IconButton(
                  onPressed: onIncrement,
                  icon: const Icon(Icons.add_circle_rounded),
                  color: AppColors.primaryColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
