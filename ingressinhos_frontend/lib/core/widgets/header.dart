import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/data/models/user_model.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';

class IngressinhosAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const IngressinhosAppBar({
    super.key,
    this.title,
    this.titleFontSize,
    this.showCartAction = true,
  });

  final String? title;
  final double? titleFontSize;
  final bool showCartAction;

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title ?? 'Ingressinhos';
    final resolvedTitleSize = titleFontSize ?? 24;

    return AppBar(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.white,
      iconTheme: IconThemeData(color: AppColors.primaryText),
      backgroundColor: AppColors.appBarBackgroundColor,
      title: Text(
        resolvedTitle,
        style: GoogleFonts.poppins(
          color: AppColors.primaryColor,
          fontSize: resolvedTitleSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: showCartAction
          ? [
              IconButton(
                tooltip: 'Carrinho',
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class IngressinhosDrawer extends StatelessWidget {
  const IngressinhosDrawer({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    final storage = getIt<SecureStorageService>();

    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<UserModel?>(
                future: storage.getUserFromToken(),
                builder: (context, snapshot) {
                  final user = snapshot.data;
                  final isSeller = user?.role == 'Seller';

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: AppColors.appBarBackgroundColor,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const CircleAvatar(
                                radius: 32,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(child: _buildUserInfo(snapshot, user)),
                            ],
                          ),
                        ),
                      ),

                      _buildMenuItem(
                        Icons.home,
                        'Home',
                        () {
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                      ),
                      _buildMenuItem(
                        Icons.confirmation_num_sharp,
                        'Meus Ingressos',
                        () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/mytickets');
                        },
                      ),

                      if (isSeller)
                        _buildMenuItem(
                          Icons.add_circle_outline,
                          'Cadastrar Evento',
                          () {
                            Navigator.pop(context);
                            Navigator.pushNamed(context, '/registerevent');
                          },
                        ),

                      _buildMenuItem(
                        Icons.settings,
                        'Configurações',
                        () => Navigator.pop(context),
                      ),
                    ],
                  );
                },
              ),
            ),

            const Divider(color: Colors.grey, height: 1),
            _buildMenuItem(Icons.exit_to_app, 'Deslogar', () => onLogout?.call()),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(AsyncSnapshot<UserModel?> snapshot, UserModel? user) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Text(
        'Carregando...',
        style: TextStyle(fontSize: 18, color: AppColors.primaryText),
      );
    }

    final name = user?.name ?? 'Usuário';
    final role = user?.role ?? '';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            color: AppColors.primaryText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (role.isNotEmpty) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: role == 'Seller'
                  ? Colors.orange.withOpacity(0.25)
                  : Colors.blue.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role,
              style: GoogleFonts.poppins(
                color: role == 'Seller' ? Colors.orange[700] : Colors.blue[700],
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  ListTile _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryText),
      title: Text(
        title,
        style: GoogleFonts.poppins(color: AppColors.primaryText, fontSize: 18),
      ),
      onTap: onTap,
    );
  }
}
