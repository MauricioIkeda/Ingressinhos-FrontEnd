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
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
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
                    child: TextField(
                      style: GoogleFonts.poppins(color: Colors.white),
                      controller: nameController,

                      decoration: InputDecoration(
                        labelText: 'Nome',

                        labelStyle: GoogleFonts.poppins(color: secondaryText),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryFocus, width: 2),
                        ),
                      ),
                    ),
                  ),

                  space,

                  SizedBox(
                    width: 300,
                    child: TextField(
                      style: GoogleFonts.poppins(color: Colors.white),
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',

                        labelStyle: GoogleFonts.poppins(color: secondaryText),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryFocus, width: 2),
                        ),
                      ),
                    ),
                  ),

                  space,

                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: cpfController,
                      keyboardType: TextInputType.number,

                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        CpfInputFormatter(),
                      ],

                      style: GoogleFonts.poppins(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: 'CPF',

                        labelStyle: GoogleFonts.poppins(color: secondaryText),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryFocus, width: 2),
                        ),
                      ),
                    ),
                  ),

                  space,

                  SizedBox(
                    width: 300,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,

                      style: GoogleFonts.poppins(color: Colors.white),

                      decoration: InputDecoration(
                        labelText: 'Senha',

                        labelStyle: GoogleFonts.poppins(color: secondaryText),

                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor),
                        ),

                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryFocus, width: 2),
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
                              final name = nameController.text;

                              final email = emailController.text;

                              final cpf = cpfController.text;

                              final password = passwordController.text;

                              final userModel = RegisterUserModel(
                                name: name,
                                email: email,
                                cpf: cpf,
                                password: password,
                              );

                              context.read<AuthCubit>().register(
                                registerUserModel: userModel,
                              ).then((_) {Navigator.pushReplacementNamed(context, '/login');});
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
                          ? CircularProgressIndicator()
                          : Text(
                              'Cadastrar',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
