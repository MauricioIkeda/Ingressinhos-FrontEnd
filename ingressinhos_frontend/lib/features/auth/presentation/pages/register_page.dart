import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';
import 'package:ingressinhos_frontend/features/auth/data/models/register_user_model.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ingressinhos_frontend/features/auth/presentation/cubit/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
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
    const backgroundColor = Color(0xFF1E1E1E);
    const primaryColor = Color(0xFFFF8C42);
    const primaryFocus = Color(0xFFFFA552);
    const secondaryText = Color(0xFFBDBDBD);

    const space = SizedBox(height: 16);

    return Scaffold(
      backgroundColor: backgroundColor,

      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthRegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Usuário cadastrado com sucesso!')),
            );

            Navigator.pushReplacementNamed(context, '/login');
          }

          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
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
                          color: primaryColor,
                        ),
                      ),

                      const SizedBox(height: 40),

                      SizedBox(
                        width: 300,

                        child: TextFormField(
                          controller: nameController,

                          style: GoogleFonts.poppins(color: Colors.white),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Nome obrigatório';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: 'Nome',

                            labelStyle: GoogleFonts.poppins(
                              color: secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(color: primaryColor),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: primaryFocus,
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

                          style: GoogleFonts.poppins(color: Colors.white),

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
                              color: secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(color: primaryColor),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: primaryFocus,
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

                          style: GoogleFonts.poppins(color: Colors.white),

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'CPF obrigatório';
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            labelText: 'CPF',

                            labelStyle: GoogleFonts.poppins(
                              color: secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(color: primaryColor),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: primaryFocus,
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

                          style: GoogleFonts.poppins(color: Colors.white),

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
                              color: secondaryText,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(color: primaryColor),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),

                              borderSide: const BorderSide(
                                color: primaryFocus,
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

                                  final userModel = RegisterUserModel(
                                    name: nameController.text,
                                    email: emailController.text,
                                    cpf: cpfController.text,
                                    password: passwordController.text,
                                  );

                                  context.read<AuthCubit>().register(
                                    registerUserModel: userModel,
                                  );
                                },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,

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
                          Navigator.pushReplacementNamed(context, '/login');
                        },

                        child: Text(
                          'Fazer login',

                          style: GoogleFonts.poppins(color: secondaryText),
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
