import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/onboarding_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/home_page.dart';

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<bool> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _hasProfile();
  }

  Future<bool> _hasProfile() async {
    try {
      debugPrint('[Onboarding] Checking profile status.');
      final response = await getIt<IngressinhosDioClient>().dio
          .get(Endpoints.profileStatus)
          .timeout(const Duration(seconds: 8));

      final data = response.data as Map<String, dynamic>;
      final hasProfile =
          data['hasClientProfile'] == true || data['hasSellerProfile'] == true;
      debugPrint('[Onboarding] Profile status loaded. hasProfile=$hasProfile');

      return hasProfile;
    } catch (_) {
      debugPrint('[Onboarding] Profile status failed. Showing onboarding.');
      return false;
    }
  }

  void _retry() {
    setState(() {
      _profileFuture = _hasProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          debugPrint('[Onboarding] Profile exists. Opening home.');
          return const HomePage();
        }

        debugPrint('[Onboarding] Profile missing. Opening onboarding.');
        return OnboardingPage(
          onRetryProfileCheck: _retry,
          onLogout: () => context.read<AuthCubit>().logout(),
        );
      },
    );
  }
}
