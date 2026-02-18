import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/password_strength_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();

      final success = await authProvider.register(
        _emailController.text,
        _passwordController.text,
        name: _nameController.text,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conta criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? 'Erro ao criar conta'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleBackToLogin() {
    Navigator.of(context).pop();
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
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: authProvider.isLoading
                          ? null
                          : _handleBackToLogin,
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppTheme.textDark,
                        size: 28,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Image.asset(
                    'assets/images/register_illustration.png',
                    height: 180,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Criar conta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  CustomTextField(
                    label: 'Nome',
                    hintText: 'Seu nome completo',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    validator: Validators.name,
                    enabled: !authProvider.isLoading,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Email',
                    hintText: 'seu@email.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    enabled: !authProvider.isLoading,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Senha',
                    hintText: 'Crie uma senha forte',
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
                    onChanged: (_) => setState(() {}),
                  ),

                  PasswordStrengthIndicator(
                    password: _passwordController.text,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    label: 'Confirmar Senha',
                    hintText: 'Digite a senha novamente',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    enabled: !authProvider.isLoading,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppTheme.textGray,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: Validators.confirmPassword(
                      _passwordController.text,
                    ),
                  ),

                  const SizedBox(height: 32),

                  Center(
                    child: CustomButton(
                      text: 'Criar conta',
                      onPressed: _handleRegister,
                      isLoading: authProvider.isLoading,
                      width: 180,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Já tem conta? ',
                        style: TextStyle(color: AppTheme.textGray),
                      ),
                      GestureDetector(
                        onTap: authProvider.isLoading
                            ? null
                            : _handleBackToLogin,
                        child: const Text(
                          'Fazer login',
                          style: TextStyle(
                            color: AppTheme.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
