import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/i_totp_repository.dart';

class TotpVerificationScreen extends StatefulWidget {
  const TotpVerificationScreen({super.key});

  @override
  State<TotpVerificationScreen> createState() => _TotpVerificationScreenState();
}

class _TotpVerificationScreenState extends State<TotpVerificationScreen> {
  final _codeController = TextEditingController();
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Digite o código de 6 dígitos.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final authProvider = context.read<AuthProvider>();
    final totpRepo = context.read<ITotpRepository>();
    final userId = authProvider.user!.uid;

    final valid = await totpRepo.verifyCode(userId: userId, code: code);

    if (!mounted) return;

    if (valid) {
      authProvider.completeTotpVerification();
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Código inválido. Tente novamente.';
        _codeController.clear();
      });
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
  }

  @override
  Widget build(BuildContext context) {
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
                    Icons.lock_clock,
                    size: 80,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Verificação em dois fatores',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Abra seu app autenticador e digite o código de 6 dígitos.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppTheme.textGray),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _codeController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    autofocus: true,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      errorText: _errorMessage,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(
                          color: AppTheme.primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (_) => _verify(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isVerifying ? null : _verify,
                    child: _isVerifying
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Verificar'),
                  ),
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
