import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/header.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }

        if(state is AuthUnauthenticated) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: const IngressinhosAppBar(),
        drawer: IngressinhosDrawer(
          onLogout: () {
            Navigator.pop(context);
            context.read<AuthCubit>().logout();
          },
        ),
        body: Center(
          child: Text(
            'Home Page',
            style: GoogleFonts.poppins(
              color: AppColors.secondaryText,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
