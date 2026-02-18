import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool readOnly;
  final bool enabled;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.suffixIcon,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          enabled: enabled,
          onTap: onTap,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
