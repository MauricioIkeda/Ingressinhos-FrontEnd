import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';

class IngressinhosAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const IngressinhosAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 1,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.white,
      iconTheme: IconThemeData(color: AppColors.primaryText),
      backgroundColor: AppColors.appBarBackgroundColor,
      title: Text(
        'Ingressinhos',
        style: GoogleFonts.poppins(
          color: AppColors.primaryColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class IngressinhosDrawer extends StatelessWidget {
  const IngressinhosDrawer({Key? key, this.onLogout}) : super(key: key);

  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColors.appBarBackgroundColor,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(),
                        SizedBox(width: 16),
                        Text(
                          'Mauricio Ikeda',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryText,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home, color: AppColors.primaryText),
                  title: Text(
                    'Home',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryText,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.confirmation_num_sharp, color: AppColors.primaryText),
                  title: Text(
                    'Meus Ingressos',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryText,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.settings, color: AppColors.primaryText),
                  title: Text(
                    'Configurações',
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryText,
                      fontSize: 18,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          Divider(color: AppColors.secondaryText.withOpacity(0.3), height: 1),
          ListTile(
            leading: Icon(Icons.exit_to_app, color: AppColors.primaryText),
            title: Text(
              'Deslogar',
              style: GoogleFonts.poppins(
                color: AppColors.primaryText,
                fontSize: 18,
              ),
            ),
            onTap: () {
              onLogout?.call();
            },
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
