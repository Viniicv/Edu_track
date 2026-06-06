import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../services/auth_service.dart';
import '../widgets/logo_widget.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialError;

  const LoginScreen({
    super.key,
    this.initialError,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    if (widget.initialError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMessage(widget.initialError!, isError: true);
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu e-mail';
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Digite um e-mail vÃ¡lido';
    }

    if (!AuthService.isInstitutionalEmail(value)) {
      return 'Use seu e-mail @souunit.com.br';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Digite sua senha';
    }

    if (value.length < 6) {
      return 'A senha deve ter no mÃ­nimo 6 caracteres';
    }

    return null;
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await _runAuthAction(() async {
      await AuthService.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
    });
  }

  Future<void> _loginWithGoogle() async {
    await _runAuthAction(() async {
      await AuthService.instance.signInWithGoogle();
    });
  }

  Future<void> _runAuthAction(Future<void> Function() action) async {
    setState(() => _isLoading = true);

    try {
      await action();

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on AuthDomainException {
      _showMessage(
        'Acesso permitido apenas para contas @souunit.com.br.',
        isError: true,
      );
    } on GoogleSignInException catch (error) {
      _showMessage(_mapGoogleSignInError(error), isError: true);
    } on FirebaseAuthException catch (error) {
      _showMessage(_mapFirebaseAuthError(error), isError: true);
    } on PlatformException catch (error) {
      _showMessage(_mapPlatformError(error), isError: true);
    } catch (error) {
      _showMessage(
        'Não foi possível entrar: ${error.runtimeType}',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'E-mail ou senha invÃ¡lidos.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'network-request-failed':
        return 'Sem conexÃ£o com a internet.';
      default:
        return 'Erro ao autenticar. Tente novamente.';
    }
  }

  String _mapGoogleSignInError(GoogleSignInException error) {
    switch (error.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Login com Google cancelado. Se vocÃª escolheu uma conta, confira o SHA-1/SHA-256 no Firebase.';
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Google Sign-In mal configurado. Confira SHA-1/SHA-256 e o google-services.json.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'NÃ£o foi possÃ­vel abrir a tela do Google Sign-In.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Login com Google interrompido. Tente novamente.';
      default:
        return error.description ?? 'NÃ£o foi possÃ­vel entrar com Google.';
    }
  }

  String _mapPlatformError(PlatformException error) {
    final details = [
      error.code,
      if (error.message != null) error.message,
    ].join(' - ');

    return 'Erro técnico no Google Sign-In: $details';
  }

  void _showMessage(String message, {required bool isError}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Center(
                  child: LogoWidget(size: 80, showText: true),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Faça login para continuar:',
                    style: AppTextStyles.subtitle,
                  ),
                ),
                const SizedBox(height: 48),
                Text('E-mail', style: AppTextStyles.progressLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    hintText: 'aluno@souunit.com.br',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Senha', style: AppTextStyles.progressLabel),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  decoration: InputDecoration(
                    hintText: '********',
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'ENTRAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: IconButton(
                    tooltip: 'Entrar com Google',
                    onPressed: _isLoading ? null : _loginWithGoogle,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Esqueceu a sua senha?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Não tem uma conta? ',
                      style: AppTextStyles.progressLabel,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Cadastre-se',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
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
