import 'package:brasil_fields/brasil_fields.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/core/storage/secure_storage_service.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, this.onRetryProfileCheck, this.onLogout});

  final VoidCallback? onRetryProfileCheck;
  final VoidCallback? onLogout;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _documentController = TextEditingController();
  final _tradingNameController = TextEditingController();

  var _isSeller = false;
  var _loading = false;
  var _loadingIdentity = true;
  String? _name;
  String? _email;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  @override
  void dispose() {
    _documentController.dispose();
    _tradingNameController.dispose();
    super.dispose();
  }

  Future<void> _loadIdentity() async {
    try {
      debugPrint('[Onboarding] Loading identity from access token.');
      final identity = await getIt<SecureStorageService>()
          .getIdentityFromToken();

      if (!mounted) {
        return;
      }

      setState(() {
        _name = identity.name;
        _email = identity.email;
        _loadingIdentity = false;
      });
      debugPrint('[Onboarding] Identity loaded. name=$_name email=$_email');
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loadingIdentity = false;
        _error = 'Nao foi possivel ler sua conta SentinelAuth.';
      });
      debugPrint('[Onboarding] Failed to load identity from token.');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if ((_name == null || _name!.isEmpty) ||
        (_email == null || _email!.isEmpty)) {
      setState(() {
        _error = 'Sua conta SentinelAuth nao retornou nome ou e-mail.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = getIt<IngressinhosDioClient>().dio;
      final document = UtilBrasilFields.removeCaracteres(
        _documentController.text,
      );

      if (_isSeller) {
        await dio.post(
          Endpoints.onboardSeller,
          data: {
            'name': _name,
            'email': _email,
            'cnpj': document,
            'tradingName': _tradingNameController.text.trim(),
          },
        );
      } else {
        await dio.post(
          Endpoints.onboardClient,
          data: {'name': _name, 'email': _email, 'cpf': document},
        );
      }

      if (!mounted) {
        return;
      }

      await context.read<AuthCubit>().checkAuthentication();
      widget.onRetryProfileCheck?.call();
    } on DioException catch (e) {
      setState(() {
        _error = mapDioError(e, 'Nao foi possivel criar seu perfil');
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IngressinhosScaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _loadingIdentity
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryColor),
            )
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.secondaryColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.24),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Header(name: _name, email: _email),
                          if (widget.onLogout != null) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: widget.onLogout,
                                icon: const Icon(Icons.logout_rounded),
                                label: const Text('Trocar conta'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          _ProfileSelector(
                            isSeller: _isSeller,
                            onChanged: (value) {
                              setState(() {
                                _isSeller = value;
                                _documentController.clear();
                              });
                            },
                          ),
                          const SizedBox(height: 22),
                          _InputLabel(text: _isSeller ? 'CNPJ' : 'CPF'),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _documentController,
                            keyboardType: TextInputType.number,
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryText,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _isSeller
                                  ? CnpjInputFormatter()
                                  : CpfInputFormatter(),
                            ],
                            decoration: _inputDecoration(
                              hintText: _isSeller
                                  ? '00.000.000/0000-00'
                                  : '000.000.000-00',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (value) {
                              final document =
                                  UtilBrasilFields.removeCaracteres(
                                    value ?? '',
                                  );
                              final expectedLength = _isSeller ? 14 : 11;

                              if (document.length != expectedLength) {
                                return _isSeller
                                    ? 'Informe um CNPJ valido'
                                    : 'Informe um CPF valido';
                              }

                              return null;
                            },
                          ),
                          if (_isSeller) ...[
                            const SizedBox(height: 16),
                            const _InputLabel(text: 'Nome da loja'),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _tradingNameController,
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryText,
                              ),
                              decoration: _inputDecoration(
                                hintText: 'Ex.: Ingressinhos Producoes',
                                icon: Icons.storefront_outlined,
                              ),
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                  ? 'Informe o nome da loja'
                                  : null,
                            ),
                          ],
                          if (_error != null) ...[
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.errorColor.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.errorColor.withValues(
                                    alpha: 0.36,
                                  ),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: GoogleFonts.poppins(
                                  color: AppColors.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loading ? null : _submit,
                            icon: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.arrow_forward_rounded),
                            label: Text(
                              _loading ? 'Criando perfil...' : 'Continuar',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              foregroundColor: AppColors.primaryText,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: GoogleFonts.poppins(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.poppins(color: AppColors.secondaryText),
      prefixIcon: Icon(icon, color: AppColors.primaryFocus),
      filled: true,
      fillColor: AppColors.backgroundColor,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryFocus, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.errorColor, width: 2),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.name, required this.email});

  final String? name;
  final String? email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.28),
            ),
          ),
          child: const Icon(
            Icons.person_pin_circle_outlined,
            color: AppColors.primaryFocus,
            size: 32,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Complete seu perfil',
          style: GoogleFonts.poppins(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: AppColors.primaryText,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sua conta SentinelAuth ja esta conectada. Agora escolha como voce quer usar o Ingressinhos.',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: AppColors.secondaryText,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.secondaryColor),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.successColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name?.isNotEmpty == true ? name! : 'Conta SentinelAuth',
                      style: GoogleFonts.poppins(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email?.isNotEmpty == true
                          ? email!
                          : 'E-mail validado no SentinelAuth',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.secondaryText,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSelector extends StatelessWidget {
  const _ProfileSelector({required this.isSeller, required this.onChanged});

  final bool isSeller;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ProfileOption(
            selected: !isSeller,
            icon: Icons.confirmation_number_outlined,
            title: 'Cliente',
            subtitle: 'Comprar e acompanhar ingressos',
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ProfileOption(
            selected: isSeller,
            icon: Icons.storefront_outlined,
            title: 'Vendedor',
            subtitle: 'Criar eventos e vender ingressos',
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _ProfileOption extends StatelessWidget {
  const _ProfileOption({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 148,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryColor.withValues(alpha: 0.16)
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryFocus : AppColors.secondaryColor,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.primaryFocus
                  : AppColors.secondaryText,
              size: 28,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
