import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/issued_ticket_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';

class IssuedTicketCard extends StatelessWidget {
  final IssuedTicketModel ticket;

  static const double aspectRatio = 1.90;

  const IssuedTicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackground = isDarkMode ? AppColors.surfaceColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final title = ticket.eventName.trim().isNotEmpty
        ? ticket.eventName
        : 'Evento sem nome';
    final locationLabel = (ticket.locationName?.trim().isNotEmpty == true)
        ? ticket.locationName!.trim()
        : 'Local a definir';
    final ticketLabel = (ticket.ticketName?.trim().isNotEmpty == true)
        ? ticket.ticketName!.trim()
        : 'Ingresso';
    final categoryLabel = (ticket.category?.trim().isNotEmpty == true)
        ? ticket.category!.trim()
        : 'Categoria';
    final statusLabel = ticket.status.trim().isNotEmpty
        ? ticket.status.trim()
        : 'Issued';
    final accessCodeLabel = ticket.accessCode.trim().isNotEmpty
        ? ticket.accessCode.trim()
        : 'Sem codigo';
    final dateLabel =
        _formatDate(ticket.eventStartTimeUtc ?? ticket.issuedAtUtc);

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: _TicketImage(imageUrl: ticket.eventImageUrl),
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _StatusBadge(
                        text: statusLabel,
                        color: _statusColor(statusLabel),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_month_rounded,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          dateLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          locationLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number_outlined,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ticketLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.local_activity_outlined,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          categoryLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: secondaryTextColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.key_rounded,
                        size: 16,
                        color: secondaryTextColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        accessCodeLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Sem data';

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
      return const Color(0xFFEF4444);
    }
    if (lowered.contains('pend') || lowered.contains('aguard')) {
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF22C55E);
  }
}

class _TicketImage extends StatelessWidget {
  final String? imageUrl;

  const _TicketImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
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
              color: Colors.white, size: 52),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.grey.shade800,
        child: const Center(
          child: Icon(Icons.broken_image_rounded, size: 48, color: Colors.grey),
        ),
      ),
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey.shade900,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 3)),
        );
      },
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;

  const _StatusBadge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
