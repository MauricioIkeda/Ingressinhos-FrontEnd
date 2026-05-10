import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/login_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {

        if (state is AuthInitial) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          return const HomePage();
        }

        if (state is AuthUnauthenticated || state is AuthLoading || state is AuthError) {
          return const LoginPage();
        }

        return const Scaffold(
          body: Center(
            child: Text('Estado desconhecido'),
          ),
        );
      },
    );
  }
}
