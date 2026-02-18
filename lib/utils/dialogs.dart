import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../widgets/common/password_strength_indicator.dart';

class AppDialogs {
  static Future<T> showLoading<T>(
    BuildContext context, {
    required Future<T> Function() operation,
    String message = 'Aguarde...',
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(color: AppTheme.primaryGreen),
              const SizedBox(width: 24),
              Text(message),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await operation();
      if (context.mounted) Navigator.pop(context);
      return result;
    } catch (e) {
      if (context.mounted) Navigator.pop(context);
      rethrow;
    }
  }

  static Future<bool> confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Sair'),
            content: const Text('Deseja realmente sair da sua conta?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Sair'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<String?> editName(
    BuildContext context, {
    required String currentName,
  }) async {
    final controller = TextEditingController(text: currentName);

    return await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nome'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nome',
            hintText: 'Digite seu nome',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                Navigator.pop(ctx, name);
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryGreen),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  static Future<Map<String, String>?> changePassword(
    BuildContext context,
  ) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Alterar senha'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha atual'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Informe a senha atual' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nova senha'),
                  onChanged: (_) => setDialogState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a nova senha';
                    if (!PasswordStrengthIndicator.isValid(v)) {
                      return 'A senha não atende todos os critérios';
                    }
                    return null;
                  },
                ),
                PasswordStrengthIndicator(password: newController.text),
                const SizedBox(height: 16),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar nova senha',
                  ),
                  validator: (v) {
                    if (v != newController.text) return 'Senhas não conferem';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(ctx, {
                    'currentPassword': currentController.text,
                    'newPassword': newController.text,
                  });
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
              ),
              child: const Text('Alterar'),
            ),
          ],
        ),
      ),
    );
  }
}
