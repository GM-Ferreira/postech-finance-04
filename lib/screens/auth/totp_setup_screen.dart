import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/i_totp_repository.dart';

class TotpSetupScreen extends StatefulWidget {
  const TotpSetupScreen({super.key});

  @override
  State<TotpSetupScreen> createState() => _TotpSetupScreenState();
}

class _TotpSetupScreenState extends State<TotpSetupScreen> {
  final _codeController = TextEditingController();
  String? _secret;
  String? _qrUri;
  bool _isLoading = true;
  bool _isVerifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateSecret();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _generateSecret() async {
    final authProvider = context.read<AuthProvider>();
    final totpRepo = context.read<ITotpRepository>();
    final userId = authProvider.user!.uid;
    final email = authProvider.user!.email ?? '';

    final secret = await totpRepo.generateSecret(userId);
    final qrUri = totpRepo.getQrUri(secret: secret, email: email);

    setState(() {
      _secret = secret;
      _qrUri = qrUri;
      _isLoading = false;
    });
  }

  Future<void> _verifyAndEnable() async {
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
      await totpRepo.enable(userId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Autenticação em dois fatores ativada!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Código inválido. Verifique e tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar 2FA'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.security,
                      size: 48,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Configure seu autenticador',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escaneie o QR Code abaixo com seu app autenticador '
                    '(Google Authenticator, Authy, Microsoft Authenticator)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                  ),
                  const SizedBox(height: 24),

                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: QrImageView(
                      data: _qrUri!,
                      version: QrVersions.auto,
                      size: 200,
                      gapless: true,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Manual key
                  Text(
                    'Ou insira a chave manualmente:',
                    style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.inputBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            _secret!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy,
                            color: AppTheme.primaryGreen,
                          ),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _secret!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chave copiada!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Copiar chave',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Verification code input
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Digite o código de 6 dígitos do autenticador:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _codeController,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        fontSize: 24,
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _verifyAndEnable,
                      child: _isVerifying
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Ativar'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
