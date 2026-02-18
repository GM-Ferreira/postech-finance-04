import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register_screen.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.login(
        _emailController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao fazer login'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Image.asset(
                    'assets/images/login_illustration.png',
                    height: 220,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 40),

                  CustomTextField(
                    label: 'Email',
                    hintText: 'seu@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    enabled: !authProvider.isLoading,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Senha',
                    hintText: 'Sua senha',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    enabled: !authProvider.isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: Validators.password,
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: CustomButton(
                      text: 'Entrar',
                      onPressed: _handleLogin,
                      isLoading: authProvider.isLoading,
                      width: 150,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Não tem conta? ',
                        style: TextStyle(color: AppTheme.textGray),
                      ),
                      GestureDetector(
                        onTap: _handleRegister,
                        child: const Text(
                          'Criar conta',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
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
      ),
    );
  }
}
