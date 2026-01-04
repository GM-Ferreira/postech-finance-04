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
    if (value.length < 6) {
      return 'A senha deve ter pelo menos 6 caracteres';
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
