import 'package:flutter/material.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/pages/onboarding_page.dart';
import 'package:ingressinhos_frontend/features/home/presentation/pages/home_page.dart';

class ProfileGate extends StatelessWidget {
  const ProfileGate({super.key});

  Future<bool> _hasProfile() async {
    final response = await getIt<IngressinhosDioClient>().dio.get(
      Endpoints.profileStatus,
    );

    final data = response.data as Map<String, dynamic>;
    return data['hasClientProfile'] == true || data['hasSellerProfile'] == true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data == true) {
          return const HomePage();
        }

        return const OnboardingPage();
      },
    );
  }
}
