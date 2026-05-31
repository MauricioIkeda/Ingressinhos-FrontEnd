import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/dependecy_injection/injection.dart';
import 'package:ingressinhos_frontend/core/network/clients/ingressinhos_dio_client.dart';
import 'package:ingressinhos_frontend/core/network/endpoints.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_scaffold.dart';
import 'package:ingressinhos_frontend/features/auth/data/exceptions/mapdioerror.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _tradingNameController = TextEditingController();
  var _isSeller = false;
  var _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _tradingNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final dio = getIt<IngressinhosDioClient>().dio;
      if (_isSeller) {
        await dio.post(
          Endpoints.onboardSeller,
          data: {
            'name': _nameController.text,
            'email': _emailController.text,
            'cnpj': _documentController.text,
            'tradingName': _tradingNameController.text,
          },
        );
      } else {
        await dio.post(
          Endpoints.onboardClient,
          data: {
            'name': _nameController.text,
            'email': _emailController.text,
            'cpf': _documentController.text,
          },
        );
      }

      if (!mounted) {
        return;
      }

      await context.read<AuthCubit>().checkAuthentication();
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Complete seu perfil',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escolha como voce quer usar o Ingressinhos.',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Cliente')),
                      ButtonSegment(value: true, label: Text('Vendedor')),
                    ],
                    selected: {_isSeller},
                    onSelectionChanged: (value) {
                      setState(() => _isSeller = value.first);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o nome'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o e-mail'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _documentController,
                    decoration: InputDecoration(
                      labelText: _isSeller ? 'CNPJ' : 'CPF',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe o documento'
                        : null,
                  ),
                  if (_isSeller) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _tradingNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da loja',
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Informe o nome da loja'
                          : null,
                    ),
                  ],
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Continuar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
