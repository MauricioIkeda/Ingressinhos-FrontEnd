import 'dart:async';
import 'dart:math';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AppLinks _appLinks = AppLinks();
  final SecureStorageService _storage = getIt<SecureStorageService>();
  StreamSubscription<Uri>? _linkSubscription;
  bool _isCompletingLogin = false;
  String? _lastHandledCallback;

  @override
  void initState() {
    super.initState();
    _listenForOAuthCallback();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _listenForOAuthCallback() {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        unawaited(_handleOAuthCallback(uri));
      }
    });

    _linkSubscription = _appLinks.uriLinkStream.listen(
      (uri) => unawaited(_handleOAuthCallback(uri)),
      onError: (_) {
        if (!mounted) {
          return;
        }

        showErrorSnackBar(
          context,
          'Nao foi possivel ler o retorno do SentinelAuth.',
          true,
        );
      },
    );
  }

  Future<void> _startSentinelAuthLogin() async {
    final state = _generateState();
    await _storage.saveOAuthState(state);
    debugPrint('[OAuth] Starting SentinelAuth login with state=$state');

    final authorizeUri =
        Uri.parse('${Endpoints.sentinelAuthFrontendUrl}/authorize').replace(
          queryParameters: {
            'client_id': Endpoints.authClientId,
            'redirect_uri': Endpoints.authRedirectUri,
            'state': state,
          },
        );

    final launched = await launchUrl(
      authorizeUri,
      mode: LaunchMode.externalApplication,
    );

    if (!mounted) {
      return;
    }

    if (!launched) {
      showErrorSnackBar(
        context,
        'Nao foi possivel abrir o SentinelAuth.',
        true,
      );
    }
  }

  Future<void> _handleOAuthCallback(Uri uri) async {
    debugPrint('[OAuth] Received callback: $uri');

    if (uri.scheme != 'ingressinhos' ||
        uri.host != 'auth' ||
        uri.path != '/callback') {
      debugPrint('[OAuth] Ignored callback with unexpected route.');
      return;
    }

    final callbackKey = uri.toString();
    if (_lastHandledCallback == callbackKey) {
      debugPrint('[OAuth] Ignored duplicated callback.');
      return;
    }

    final error = uri.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      showErrorSnackBar(context, error, true);
      return;
    }

    final receivedState = uri.queryParameters['state'];
    final expectedState = await _storage.getOAuthState();
    debugPrint(
      '[OAuth] Validating state. expected=$expectedState received=$receivedState',
    );

    if (expectedState == null || receivedState != expectedState) {
      if (!mounted) {
        return;
      }

      debugPrint('[OAuth] Ignored callback without a matching pending state.');
      return;
    }

    final code = uri.queryParameters['code'];
    if (code == null || code.isEmpty) {
      if (!mounted) {
        return;
      }

      showErrorSnackBar(
        context,
        'O SentinelAuth nao retornou um codigo de autorizacao.',
        true,
      );
      return;
    }

    if (_isCompletingLogin) {
      debugPrint(
        '[OAuth] Callback ignored because login is already completing.',
      );
      return;
    }

    _isCompletingLogin = true;
    _lastHandledCallback = callbackKey;
    await _storage.clearOAuthState();
    debugPrint('[OAuth] State validated. Exchanging authorization code.');

    if (!mounted) {
      return;
    }

    context.read<AuthCubit>().completeOAuthLogin(code: code);
  }

  String _generateState() {
    final random = Random.secure();
    final values = List<int>.generate(24, (_) => random.nextInt(256));

    return values
        .map((value) => value.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            _isCompletingLogin = false;
            unawaited(_storage.clearOAuthState());
            showErrorSnackBar(context, state.message, true);
          }

          if (state is AuthServerDisconnected) {
            showErrorSnackBar(
              context,
              'Nao foi possivel conectar ao servidor. Tente novamente mais tarde.',
              true,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      margin: const EdgeInsets.only(bottom: 28),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.secondaryColor),
                      ),
                      child: const Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primaryFocus,
                        size: 34,
                      ),
                    ),
                    Text(
                      'Ingressinhos',
                      style: GoogleFonts.poppins(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Entre com sua conta global SentinelAuth para continuar.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.secondaryText,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 34),
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : _startSentinelAuthLogin,
                      icon: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.login_rounded),
                      label: Text(
                        isLoading
                            ? 'Finalizando login...'
                            : 'Entrar com SentinelAuth',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.primaryText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cadastro e login acontecem no SentinelAuth. Depois disso, o Ingressinhos pergunta se voce quer perfil de cliente ou vendedor.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
