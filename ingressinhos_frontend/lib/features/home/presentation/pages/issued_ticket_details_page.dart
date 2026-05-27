import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';

class IssuedTicketDetailsPage extends StatelessWidget {
  final IssuedTicketModel ticket;

  const IssuedTicketDetailsPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const IngressinhosAppBar(
        title: 'Detalhes do ingresso',
        titleFontSize: 22,
        showCartAction: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _HeaderImage(imageUrl: ticket.eventImageUrl),
          const SizedBox(height: 16),
          Text(
            ticket.eventName.trim().isNotEmpty
                ? ticket.eventName
                : 'Evento sem nome',
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip(
                label: ticket.status.trim().isNotEmpty
                    ? ticket.status.trim()
                    : 'Issued',
                color: _statusColor(ticket.status),
              ),
              if (ticket.category != null && ticket.category!.trim().isNotEmpty)
                _Chip(
                  label: ticket.category!.trim(),
                  color: AppColors.secondaryColor,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _DetailsCard(
            title: 'Informacoes do ingresso',
            children: [
              _DetailRow(
                label: 'Codigo de acesso',
                value: _valueOrFallback(ticket.accessCode),
              ),
              _DetailRow(
                label: 'Ingresso',
                value: _valueOrFallback(ticket.ticketName),
              ),
              _DetailRow(
                label: 'Categoria',
                value: _valueOrFallback(ticket.category),
              ),
              _DetailRow(
                label: 'Assento',
                value: _valueOrFallback(ticket.seatCode),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailsCard(
            title: 'Evento',
            children: [
              _DetailRow(
                label: 'Local',
                value: _valueOrFallback(ticket.locationName),
              ),
              _DetailRow(
                label: 'Inicio',
                value: _formatDate(ticket.eventStartTimeUtc),
              ),
              _DetailRow(
                label: 'Fim',
                value: _formatDate(ticket.eventEndTimeUtc),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _DetailsCard(
            title: 'Status',
            children: [
              _DetailRow(
                label: 'Emitido em',
                value: _formatDate(ticket.issuedAtUtc),
              ),
              _DetailRow(
                label: 'Pago em',
                value: _formatDate(ticket.paidAtUtc),
              ),
              _DetailRow(
                label: 'Check-in',
                value: _formatDate(ticket.checkedInAtUtc),
              ),
              _DetailRow(
                label: 'Cancelado em',
                value: _formatDate(ticket.cancelledAtUtc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _valueOrFallback(String? value) {
    if (value == null || value.trim().isEmpty) return 'Nao informado';
    return value;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Nao informado';

    final localDate = date.toLocal();
    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();
    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  Color _statusColor(String statusLabel) {
    final lowered = statusLabel.toLowerCase();
    if (lowered.contains('cancel') ||
        lowered.contains('expir') ||
        lowered.contains('invalid')) {
      return AppColors.errorColor;
    }
    if (lowered.contains('pend') || lowered.contains('aguard')) {
      return AppColors.warningColor;
    }
    return AppColors.successColor;
  }
}

class _HeaderImage extends StatelessWidget {
  final String? imageUrl;

  const _HeaderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: imageUrl == null || imageUrl!.isEmpty
            ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryColor,
                      AppColors.primaryColor.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.confirmation_num_rounded,
                      color: Colors.white, size: 64),
                ),
              )
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.grey.shade800,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded,
                        size: 48, color: Colors.grey),
                  ),
                ),
                loadingBuilder: (_, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 3),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;

  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
