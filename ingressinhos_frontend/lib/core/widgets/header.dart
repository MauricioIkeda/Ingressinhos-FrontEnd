import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';

class IngressinhosAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  const IngressinhosAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 2,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.white,
      iconTheme: IconThemeData(color: AppColors.secondaryText),
      backgroundColor: AppColors.appBarBackgroundColor,
      title: Text(
        'Ingressinhos',
        style: GoogleFonts.poppins(
          color: AppColors.secondaryText,
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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.appBarBackgroundColor),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    tooltip: 'Deslogar',
                    icon: Icon(Icons.logout, color: Colors.white),
                    onPressed: onLogout,
                  ),
                ),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(),
                      SizedBox(width: 16),
                      Text(
                        'Mauricio Ikeda',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: AppColors.secondaryText),
            title: Text(
              'Home',
              style: GoogleFonts.poppins(
                color: AppColors.secondaryText,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings, color: AppColors.secondaryText),
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                color: AppColors.secondaryText,
                fontSize: 18,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
