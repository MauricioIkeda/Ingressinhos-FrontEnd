import 'package:flutter/material.dart';

class MeuAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: Colors.black.withValues(alpha: 0.5),
      elevation: 10.0,

      title: Text(
        "Ingressinhos",
        style: TextStyle(
          color: const Color.fromARGB(255, 212, 154, 37),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 27, 60, 87),

      iconTheme: const IconThemeData(
        color: Color.fromARGB(255, 212, 154, 37),
      ),

      actions: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.shopping_cart,
            color: const Color.fromARGB(255, 212, 154, 37),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
