import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/profile_gate.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial) {
          return IngressinhosScaffold(
            backgroundColor: AppColors.appBarBackgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ingressinhos',
                    style: GoogleFonts.poppins(
                      fontSize: 54,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated || state is AuthServerDisconnected) {
          return const ProfileGate();
        }

        if (state is AuthUnauthenticated ||
            state is AuthError ||
            state is AuthLoading) {
          return const LoginPage();
        }

        return const IngressinhosScaffold(
          body: Center(child: Text('Estado desconhecido')),
        );
      },
    );
  }
}
