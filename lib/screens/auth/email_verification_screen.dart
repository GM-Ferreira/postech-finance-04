import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isCheckingVerification = false;

  Future<void> _resendEmail() async {
    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.sendVerificationEmail();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Email de verificação reenviado!'
              : authProvider.errorMessage ?? 'Erro ao reenviar email.',
        ),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> _checkVerification() async {
    setState(() => _isCheckingVerification = true);

    final authProvider = context.read<AuthProvider>();
    final verified = await authProvider.refreshUser();

    if (!mounted) return;

    if (!verified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Email ainda não verificado. Verifique sua caixa de entrada.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
    }

    setState(() => _isCheckingVerification = false);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? '';

    return Scaffold(
      backgroundColor: AppTheme.backgroundGray,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verifique seu email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Enviamos um link de verificação para:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.textGray),
                ),
                const SizedBox(height: 8),
                Text(
                  email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Acesse seu email e clique no link para ativar sua conta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                ),
                const SizedBox(height: 40),
                CustomButton(
                  text: 'Já verifiquei',
                  isLoading: _isCheckingVerification,
                  onPressed: _checkVerification,
                  width: double.infinity,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Reenviar email',
                  isOutlined: true,
                  isLoading: authProvider.isLoading,
                  onPressed: _resendEmail,
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: _logout,
                  child: const Text(
                    'Sair',
                    style: TextStyle(color: AppTheme.textGray, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
