import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/cart_item_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/cart_cubit.dart';
import 'package:ingressinhos_frontend/features/home/presentation/cubit/cart_state.dart';
import 'package:url_launcher/url_launcher.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: const IngressinhosAppBar(
        title: 'Carrinho',
        titleFontSize: 22,
        showCartAction: false,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            );
          }

          /*if (state.errorMessage != null) {
            return _CartError(
              message: state.errorMessage!,
              onRetry: () => context.read<CartCubit>().loadCart(),
            );
          }*/

          if (state.isEmpty) {
            return _EmptyCart(
              onExplore: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              ...state.items.map(
                (item) => _CartItemCard(
                  item: item,
                  onRemove: item.id == null
                      ? null
                      : () => context.read<CartCubit>().removeItem(
                          orderItemId: item.id!,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              _CartSummaryCard(
                totalTickets: state.totalTickets,
                totalAmount: state.totalAmount,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.items.isNotEmpty
                      ? () async {
                          final checkout = await context
                              .read<CartCubit>()
                              .checkout(orderId: state.cart!.id!);
                          if (!context.mounted) return;
                          final payload = checkout?.qrCode?.payload?.trim();
                          if (payload == null || payload.isEmpty) {
                            showErrorSnackBar(
                              context,
                              'Não foi possível abrir o pagamento.',
                              true,
                            );
                            return;
                          }
                          final uri = Uri.tryParse(payload);
                          if (uri == null) {
                            showErrorSnackBar(
                              context,
                              'Link de pagamento inválido.',
                              true,
                            );
                            return;
                          }
                          try {
                            final launched = await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                            if (!launched && context.mounted) {
                              showErrorSnackBar(
                                context,
                                'Não foi possível abrir o pagamento.',
                                true,
                              );
                            }
                          } on PlatformException {
                            if (!context.mounted) return;
                            showErrorSnackBar(
                              context,
                              'Não foi possível abrir o pagamento.',
                              true,
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Finalizar compra',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.items.isNotEmpty
                    ? () => context.read<CartCubit>().resetCart()
                    : null,
                child: Text(
                  'Limpar carrinho',
                  style: GoogleFonts.poppins(
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartError extends StatelessWidget {
  const _CartError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 56,
                color: AppColors.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Tentar novamente',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.shopping_cart_outlined,
                size: 72,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Seu carrinho está vazio',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Adicione ingressos para finalizar a compra.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onExplore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Explorar eventos',
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
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, this.onRemove});

  final CartItemModel item;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = _categoryLabel(item.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primaryColor.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.ticketName,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  tooltip: 'Remover',
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.secondaryText,
                  onPressed: onRemove,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(text: categoryLabel),
              _InfoChip(text: 'Quantidade: ${item.quantity}'),
              _InfoChip(text: 'Unitário: ${_formatCurrency(item.unitPrice)}'),
              if (item.seatCode != null && item.seatCode!.trim().isNotEmpty)
                _InfoChip(text: 'Assento: ${item.seatCode}'),
            ],
          ),
          const Divider(height: 24, color: Colors.white12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondaryText,
                ),
              ),
              Text(
                _formatCurrency(item.totalPrice),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  const _CartSummaryCard({
    required this.totalTickets,
    required this.totalAmount,
  });

  final int totalTickets;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              '$totalTickets ingresso(s) • Total: ${_formatCurrency(totalAmount)}',
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _categoryLabel(int? category) {
  switch (category) {
    case 1:
      return 'Base';
    case 2:
      return 'Premium';
    case 3:
      return 'VIP';
    default:
      return category == null ? 'Categoria' : 'Categoria $category';
  }
}

String _formatCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}
