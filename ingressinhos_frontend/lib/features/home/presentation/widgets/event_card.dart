import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/event_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;

  static const double aspectRatio = 1.90;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final title = event.name.trim().isNotEmpty ? event.name : 'Evento sem nome';

    final description = (event.description?.trim().isNotEmpty == true)
        ? event.description!
        : 'Sem descrição disponível';

    final imageUrl = event.imageUrl;
    final startTime = _formatDate(event.startTime);
    final hasSeats = event.hasSeats;
    final availableTickets = event.availableTickets ?? 0;
    final locationLabel = (event.locationName?.trim().isNotEmpty == true)
        ? event.locationName!.trim()
        : 'Local a definir';
    final ticketPrice = event.baseTicketPrice;

    final cardBackground = isDarkMode ? AppColors.surfaceColor : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final secondaryTextColor = isDarkMode
        ? Colors.grey.shade400
        : Colors.grey.shade700;
    final borderColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);

    final ticketLabel = ticketPrice != null
        ? 'R\$ ${ticketPrice.toStringAsFixed(2)}'
        : 'Preço a definir';

    final clipper = _TicketClipper(
      cornerRadius: 20,
      notchRadius: 14,
      notchPosition: 0.5,
    );

    final card = PhysicalShape(
      clipper: clipper,
      elevation: 12,
      color: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.45),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cardBackground,
              cardBackground.withValues(alpha: 0.94),
            ],
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _EventImage(imageUrl: imageUrl),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _Badge(
                          text: availableTickets > 0 ? 'COM VAGAS' : 'LOTADO',
                          backgroundColor: availableTickets > 0
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                _TicketDivider(color: borderColor),
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w700,
                            height: 1.15,
                            color: isDarkMode
                                ? Colors.white
                                : AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                                startTime,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            height: 1.4,
                            color: secondaryTextColor,
                          ),
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
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
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
                                  fontWeight: FontWeight.w500,
                                ),
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
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _TicketBorderPainter(
                    clipper: clipper,
                    color: borderColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(onTap: onTap, child: card);
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
}

class _EventImage extends StatelessWidget {
  final String? imageUrl;

  const _EventImage({required this.imageUrl});

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
          child: Icon(Icons.event_rounded, color: Colors.white, size: 52),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color backgroundColor;

  const _Badge({required this.text, required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  final Color color;

  const _TicketDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: CustomPaint(
        painter: _DashedLinePainter(color: color, axis: Axis.vertical),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  final Axis axis;

  _DashedLinePainter({required this.color, this.axis = Axis.horizontal});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    if (axis == Axis.horizontal) {
      final y = size.height / 2;
      paint.shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color,
          color,
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.15, 0.85, 1.0],
      ).createShader(Rect.fromLTWH(0, y - 1, size.width, 2));

      const dashWidth = 7.0;
      const dashGap = 5.0;
      double x = 0;
      while (x < size.width) {
        final nextX = x + dashWidth;
        canvas.drawLine(
          Offset(x, y),
          Offset(nextX.clamp(0, size.width), y),
          paint,
        );
        x += dashWidth + dashGap;
      }
      return;
    }

    final x = size.width / 2;
    paint.shader = LinearGradient(
      colors: [
        color.withValues(alpha: 0.0),
        color,
        color,
        color.withValues(alpha: 0.0),
      ],
      stops: const [0.0, 0.15, 0.85, 1.0],
    ).createShader(Rect.fromLTWH(x - 1, 0, 2, size.height));

    const dashHeight = 7.0;
    const dashGap = 5.0;
    double y = 0;
    while (y < size.height) {
      final nextY = y + dashHeight;
      canvas.drawLine(
        Offset(x, y),
        Offset(x, nextY.clamp(0, size.height)),
        paint,
      );
      y += dashHeight + dashGap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.axis != axis;
  }
}

class _TicketClipper extends CustomClipper<Path> {
  final double cornerRadius;
  final double notchRadius;
  final double notchPosition;

  _TicketClipper({
    required this.cornerRadius,
    required this.notchRadius,
    required this.notchPosition,
  });

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(cornerRadius),
        ),
      );

    final notchCenterY = size.height * notchPosition;
    final notchLeft = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(0, notchCenterY),
          radius: notchRadius,
        ),
      );
    final notchRight = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width, notchCenterY),
          radius: notchRadius,
        ),
      );

    return Path.combine(
      PathOperation.difference,
      base,
      Path.combine(PathOperation.union, notchLeft, notchRight),
    );
  }

  @override
  bool shouldReclip(covariant _TicketClipper oldClipper) {
    return cornerRadius != oldClipper.cornerRadius ||
        notchRadius != oldClipper.notchRadius ||
        notchPosition != oldClipper.notchPosition;
  }
}

class _TicketBorderPainter extends CustomPainter {
  final _TicketClipper clipper;
  final Color color;

  _TicketBorderPainter({
    required this.clipper,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final path = clipper.getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TicketBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.clipper != clipper;
  }
}
