import 'package:flutter/material.dart';

import '../../config/app_theme.dart';

enum PasswordStrength { empty, weak, medium, strong }

class PasswordCriteria {
  final String label;
  final bool met;

  const PasswordCriteria({required this.label, required this.met});
}

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  List<PasswordCriteria> get criteria => [
    PasswordCriteria(label: 'Mínimo 8 caracteres', met: password.length >= 8),
    PasswordCriteria(
      label: 'Letra maiúscula',
      met: password.contains(RegExp(r'[A-Z]')),
    ),
    PasswordCriteria(
      label: 'Letra minúscula',
      met: password.contains(RegExp(r'[a-z]')),
    ),
    PasswordCriteria(label: 'Número', met: password.contains(RegExp(r'[0-9]'))),
    PasswordCriteria(
      label: 'Caractere especial (@#\$%&*!)',
      met: password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
    ),
  ];

  PasswordStrength get strength {
    if (password.isEmpty) return PasswordStrength.empty;

    final metCount = criteria.where((c) => c.met).length;

    if (metCount <= 2) return PasswordStrength.weak;
    if (metCount <= 4) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  static bool isValid(String password) {
    return password.length >= 8 &&
        password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[a-z]')) &&
        password.contains(RegExp(r'[0-9]')) &&
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  }

  Color get _barColor {
    switch (strength) {
      case PasswordStrength.empty:
        return Colors.grey.shade300;
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.medium:
        return Colors.orange;
      case PasswordStrength.strong:
        return AppTheme.primaryGreen;
    }
  }

  String get _label {
    switch (strength) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'Fraca';
      case PasswordStrength.medium:
        return 'Média';
      case PasswordStrength.strong:
        return 'Forte';
    }
  }

  double get _barProgress {
    switch (strength) {
      case PasswordStrength.empty:
        return 0.0;
      case PasswordStrength.weak:
        return 0.33;
      case PasswordStrength.medium:
        return 0.66;
      case PasswordStrength.strong:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _barProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_barColor),
                  minHeight: 6,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _barColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ...criteria.map(
          (c) => Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Row(
              children: [
                Icon(
                  c.met ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: c.met ? AppTheme.primaryGreen : Colors.red.shade300,
                ),
                const SizedBox(width: 8),
                Text(
                  c.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: c.met ? AppTheme.textDark : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
