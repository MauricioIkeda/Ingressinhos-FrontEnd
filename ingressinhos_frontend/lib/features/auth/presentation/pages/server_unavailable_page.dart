import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';

class ServerUnavailablePage extends StatefulWidget {
  const ServerUnavailablePage({
    super.key,
    required this.onRetry,
    required this.onLogout,
  });

  final Future<void> Function() onRetry;
  final Future<void> Function() onLogout;

  @override
  State<ServerUnavailablePage> createState() => _ServerUnavailablePageState();
}

class _ServerUnavailablePageState extends State<ServerUnavailablePage> {
  var _retrying = false;
  var _loggingOut = false;

  Future<void> _runRetry() async {
    if (_retrying || _loggingOut) return;

    setState(() => _retrying = true);
    try {
      await widget.onRetry();
    } finally {
      if (mounted) {
        setState(() => _retrying = false);
      }
    }
  }

  Future<void> _runLogout() async {
    if (_retrying || _loggingOut) return;

    setState(() => _loggingOut = true);
    try {
      await widget.onLogout();
    } finally {
      if (mounted) {
        setState(() => _loggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.secondaryColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.warningColor.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.warningColor.withValues(
                              alpha: 0.34,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.warningColor,
                          size: 34,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Servidor indisponivel',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryText,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nao conseguimos falar com as APIs do Ingressinhos agora. Sua conta continua salva neste aparelho; quando o servidor voltar, tente novamente.',
                      style: GoogleFonts.poppins(
                        color: AppColors.secondaryText,
                        fontSize: 14.5,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.secondaryColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.primaryFocus,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Nao vamos pedir para escolher cliente ou vendedor enquanto nao conseguirmos confirmar seu perfil.',
                              style: GoogleFonts.poppins(
                                color: AppColors.secondaryText,
                                fontSize: 13.5,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _retrying || _loggingOut ? null : _runRetry,
                      icon: _retrying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: Text(
                        _retrying ? 'Tentando...' : 'Tentar novamente',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: _retrying || _loggingOut ? null : _runLogout,
                      icon: _loggingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.logout_rounded),
                      label: Text(_loggingOut ? 'Saindo...' : 'Sair da conta'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
