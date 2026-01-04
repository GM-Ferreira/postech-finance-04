import 'package:flutter/material.dart';
import 'package:postech_finance_03/config/app_theme.dart';
import 'package:postech_finance_03/utils/validators.dart';
import 'package:postech_finance_03/widgets/common/custom_button.dart';
import 'package:postech_finance_03/widgets/common/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implementar autenticação com Firebase
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // TODO: Navegar para a próxima tela
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login será implementado com Firebase')),
        );
      });
    }
  }

  void _handleRegister() {
    // TODO - Implementar navegação para tela de registro
  }

  @override
  Widget build(BuildContext context) {
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
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Senha',
                    hintText: 'Sua senha',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
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
                      isLoading: _isLoading,
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
