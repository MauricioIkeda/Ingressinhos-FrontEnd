import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/list_events_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          showErrorSnackBar(context, state.message, true);
        }

        if (state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return IngressinhosScaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: const IngressinhosAppBar(),
            drawer: IngressinhosDrawer(
              onLogout: () {
                Navigator.pop(context);
                context.read<AuthCubit>().logout();
              },
            ),
            body: Column(
              children: [
                if (state is AuthServerDisconnected)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    color: Colors.orange.shade700,
                    child: Center(
                      child: Text(
                        'Sem conexão com o servidor.',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                
                Expanded(child: ListEventPage(),)
              ],
            ),
          );
        },
      ),
    );
  }
}
