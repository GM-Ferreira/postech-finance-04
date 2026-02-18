class Validators {
  Validators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Por favor, insira um email válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, insira sua senha';
    }
    if (value.length < 8) {
      return 'A senha deve ter pelo menos 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'A senha deve conter pelo menos uma letra maiúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'A senha deve conter pelo menos uma letra minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'A senha deve conter pelo menos um número';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'A senha deve conter pelo menos um caractere especial';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor, insira seu nome';
    }
    if (value.trim().length < 3) {
      return 'O nome deve ter pelo menos 3 caracteres';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Por favor, confirme sua senha';
      }
      if (value != password) {
        return 'As senhas não coincidem';
      }
      return null;
    };
  }
}
