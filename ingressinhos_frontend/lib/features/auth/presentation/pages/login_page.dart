import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ingressinhos_frontend/core/theme/app_colors.dart';
import 'package:ingressinhos_frontend/core/widgets/app_snack_bar.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/login_user_model.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();

  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 16);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,

      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacementNamed(context, '/home');
          }

          if (state is AuthError) {
            showErrorSnackBar(context, state.message, true);
          }
        },

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
                        controller: emailController,

                        style: GoogleFonts.poppins(color: AppColors.primaryText),

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

                          labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),

                            borderSide: const BorderSide(color: AppColors.primaryColor),
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

                        style: GoogleFonts.poppins(color: AppColors.primaryText),

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

                          labelStyle: GoogleFonts.poppins(color: AppColors.secondaryText),

                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),

                            borderSide: const BorderSide(color: AppColors.primaryColor),
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

                                final userModel = LoginUserModel(
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                );

                                context.read<AuthCubit>().login(
                                  loginUserModel: userModel,
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
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryText,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Logar',

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
                        Navigator.pushReplacementNamed(context, '/register');
                      },

                      child: Text(
                        'Criar uma conta',

                        style: GoogleFonts.poppins(color: AppColors.secondaryText),
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
