import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/register_user_client_model.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';

class RegisterClientPage extends StatefulWidget {
  const RegisterClientPage({super.key});

  @override
  State<RegisterClientPage> createState() => _RegisterClientPageState();
}

class _RegisterClientPageState extends State<RegisterClientPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();

  final emailController = TextEditingController();

  final cpfController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cpfController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 16);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            showErrorSnackBar(
              context,
              'Usuário cadastrado com sucesso!',
              false,
            );

            Navigator.pushReplacementNamed(context, '/login');
          }

          if (state is AuthError) {
            showErrorSnackBar(context, state.message, true);
          }
        },

        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            return Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,

                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: [
                      Text(
                        'Ingressinhos',

                        style: GoogleFonts.poppins(
                          fontSize: 54,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryColor,
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: 300,

                        child: TextFormField(
                          controller: nameController,

                          style: GoogleFonts.poppins(
                            color: AppColors.primaryText,
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nome obrigatório';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: 'Nome',

                            labelStyle: GoogleFonts.poppins(
                              color: AppColors.secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      space,

                      SizedBox(
                        width: 300,

                        child: TextFormField(
                          controller: emailController,

                          style: GoogleFonts.poppins(
                            color: AppColors.primaryText,
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'E-mail obrigatório';
                            }

                            if (!value.contains('@')) {
                              return 'E-mail inválido';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: 'E-mail',

                            labelStyle: GoogleFonts.poppins(
                              color: AppColors.secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      space,

                      SizedBox(
                        width: 300,

                        child: TextFormField(
                          controller: cpfController,

                          keyboardType: TextInputType.number,

                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            CpfInputFormatter(),
                          ],

                          style: GoogleFonts.poppins(
                            color: AppColors.primaryText,
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'CPF obrigatório';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: 'CPF',

                            labelStyle: GoogleFonts.poppins(
                              color: AppColors.secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      space,

                      SizedBox(
                        width: 300,

                        child: TextFormField(
                          controller: passwordController,

                          obscureText: true,

                          style: GoogleFonts.poppins(
                            color: AppColors.primaryText,
                          ),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Senha obrigatória';
                            }

                            if (value.length < 6) {
                              return 'Senha deve ter pelo menos 6 caracteres';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: 'Senha',

                            labelStyle: GoogleFonts.poppins(
                              color: AppColors.secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryColor,
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: AppColors.primaryFocus,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: 300,

                        child: ElevatedButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  final isValid = _formKey.currentState!
                                      .validate();

                                  if (!isValid) {
                                    return;
                                  }

                                  final userClientModel =
                                      RegisterUserClientModel(
                                        name: nameController.text,
                                        email: emailController.text,
                                        cpf: cpfController.text,
                                        password: passwordController.text,
                                      );

                                  context.read<AuthCubit>().registerClient(
                                    registerUserModel: userClientModel,
                                  );
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            foregroundColor: AppColors.primaryText,

                            padding: const EdgeInsets.symmetric(vertical: 16),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                          child: state is AuthLoading
                              ? const CircularProgressIndicator()
                              : Text(
                                  'Cadastrar',

                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/registerseller');
                        },

                        child: Text(
                          'Cadastrar como vendedor',

                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },

                        child: Text(
                          'Fazer login',

                          style: GoogleFonts.poppins(
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
