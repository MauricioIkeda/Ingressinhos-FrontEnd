import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/register_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const primaryColor = Color(0xFFFF8C42);
    const primaryFocus = Color(0xFFFFA552);
    const secondaryText = Color(0xFFBDBDBD);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Ingressinhos',
              style: GoogleFonts.poppins(
                fontSize: 54,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: 300,
              child: TextField(
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                  labelText: 'E-mail',

                  labelStyle: GoogleFonts.poppins(
                    color: secondaryText,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: primaryFocus,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 300,
              child: TextField(
                obscureText: true,

                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),

                decoration: InputDecoration(
                  labelText: 'Senha',

                  labelStyle: GoogleFonts.poppins(
                    color: secondaryText,
                  ),

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: primaryColor,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: primaryFocus,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: 300,
              child: ElevatedButton(
                onPressed: () {},

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,

                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(
                  'Logar',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const RegisterPage(),
                ));
              },
              child: Text(
                'Não possuo uma conta',
                style: GoogleFonts.poppins(
                  color: secondaryText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}