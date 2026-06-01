import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/onboarding_page.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/server_unavailable_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/home_page.dart';

enum _ProfileGateResult { hasProfile, missingProfile, serverUnavailable }

class ProfileGate extends StatefulWidget {
  const ProfileGate({super.key});

  @override
  State<ProfileGate> createState() => _ProfileGateState();
}

class _ProfileGateState extends State<ProfileGate> {
  late Future<_ProfileGateResult> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileStatus();
  }

  Future<_ProfileGateResult> _loadProfileStatus() async {
    try {
      debugPrint('[Onboarding] Checking profile status.');
      final response = await getIt<IngressinhosDioClient>().dio
          .get(Endpoints.profileStatus)
          .timeout(const Duration(seconds: 8));

      final data = response.data as Map<String, dynamic>;
      final hasProfile =
          data['hasClientProfile'] == true || data['hasSellerProfile'] == true;
      debugPrint('[Onboarding] Profile status loaded. hasProfile=$hasProfile');

      return hasProfile
          ? _ProfileGateResult.hasProfile
          : _ProfileGateResult.missingProfile;
    } catch (_) {
      debugPrint('[Onboarding] Profile status failed. Showing server offline.');
      return _ProfileGateResult.serverUnavailable;
    }
  }

  Future<void> _retry() async {
    setState(() {
      _profileFuture = _loadProfileStatus();
    });
    await _profileFuture;
  }

  Future<void> _logout() {
    return context.read<AuthCubit>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ProfileGateResult>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final result = snapshot.data;

        if (result == _ProfileGateResult.hasProfile) {
          debugPrint('[Onboarding] Profile exists. Opening home.');
          return const HomePage();
        }

        if (result == _ProfileGateResult.serverUnavailable) {
          return ServerUnavailablePage(onRetry: _retry, onLogout: _logout);
        }

        debugPrint('[Onboarding] Profile missing. Opening onboarding.');
        return OnboardingPage(onRetryProfileCheck: _retry, onLogout: _logout);
      },
    );
  }
}
