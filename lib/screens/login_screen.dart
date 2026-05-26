import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/theme.dart';
import '../widgets/logo_widget.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState
    extends State<LoginScreen> {

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // FORM
  final _formKey =
      GlobalKey<FormState>();

  // VALIDAÇÃO EMAIL
  String? _validateEmail(
      String? value) {

    if (value == null ||
        value.trim().isEmpty) {
      return 'Digite seu e-mail';
    }

    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(
        value.trim())) {
      return 'Digite um e-mail válido';
    }

    return null;
  }

  // VALIDAÇÃO SENHA
  String? _validatePassword(
      String? value) {

    if (value == null ||
        value.isEmpty) {
      return 'Digite sua senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }

    return null;
  }

  Future<void> _login() async {

    // VALIDA FORMULÁRIO
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(
      const Duration(seconds: 1),
    );

    final prefs =
        await SharedPreferences
            .getInstance();

    await prefs.setBool(
      'isLoggedIn',
      true,
    );

    await prefs.setString(
      'userName',
      _emailController.text
          .split('@')[0],
    );

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: Padding(
            padding:
                const EdgeInsets.all(24),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                const SizedBox(
                    height: 60),

                // LOGO
                const Center(
                  child: LogoWidget(
                    size: 80,
                    showText: true,
                  ),
                ),

                const SizedBox(
                    height: 24),

                Center(
                  child: Text(
                    'Faça login para continuar:',
                    style:
                        AppTextStyles
                            .subtitle,
                  ),
                ),

                const SizedBox(
                    height: 48),

                // EMAIL
                Text(
                  'E-mail',
                  style:
                      AppTextStyles
                          .progressLabel,
                ),

                const SizedBox(
                    height: 8),

                TextFormField(
                  controller:
                      _emailController,

                  keyboardType:
                      TextInputType
                          .emailAddress,

                  validator:
                      _validateEmail,

                  decoration:
                      const InputDecoration(
                    hintText:
                        'aluno@email.com',

                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(
                        Radius.circular(
                            12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 20),

                // SENHA
                Text(
                  'Senha',
                  style:
                      AppTextStyles
                          .progressLabel,
                ),

                const SizedBox(
                    height: 8),

                TextFormField(
                  controller:
                      _passwordController,

                  obscureText:
                      _obscurePassword,

                  validator:
                      _validatePassword,

                  decoration:
                      InputDecoration(
                    hintText:
                        '********',

                    border:
                        const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(
                        Radius.circular(
                            12),
                      ),
                    ),

                    suffixIcon:
                        IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons
                                .visibility_off
                            : Icons
                                .visibility,
                      ),

                      onPressed: () {
                        setState(() {
                          _obscurePassword =
                              !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(
                    height: 24),

                // BOTÃO LOGIN
                SizedBox(
                  width:
                      double.infinity,

                  child: ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _login,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          AppColors
                              .primary,

                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 16,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),

                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2,
                              color: Colors
                                  .white,
                            ),
                          )
                        : const Text(
                            'ENTRAR',

                            style:
                                TextStyle(
                              fontSize:
                                  16,

                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                    height: 16),

                // ESQUECEU SENHA
                Center(
                  child: TextButton(
                    onPressed: () {},

                    child: const Text(
                      'Esqueceu a sua senha?',

                      style: TextStyle(
                        color: AppColors
                            .textSecondary,

                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                    height: 32),

                // CADASTRO
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [
                    Text(
                      'Não tem uma conta? ',

                      style:
                          AppTextStyles
                              .progressLabel,
                    ),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const RegisterScreen(),
                          ),
                        );
                      },

                      child: const Text(
                        'Cadastre-se',

                        style:
                            TextStyle(
                          color:
                              AppColors
                                  .primary,

                          fontWeight:
                              FontWeight
                                  .w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}