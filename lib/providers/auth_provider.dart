import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/auth_exception.dart';
import '../repositories/i_auth_repository.dart';
import '../repositories/i_totp_repository.dart';
import '../services/observability_service.dart';

class AuthProvider extends ChangeNotifier {
  final IAuthRepository _repository;
  final ITotpRepository _totpRepository;

  AppUser? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _pendingTotpVerification = false;
  bool _isLoggingIn = false;
  bool _totpVerifiedThisSession = false;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;
  bool get pendingTotpVerification => _pendingTotpVerification;
  String? get errorMessage => _errorMessage;

  AuthProvider({
    required IAuthRepository repository,
    required ITotpRepository totpRepository,
  }) : _repository = repository,
       _totpRepository = totpRepository {
    _repository.authStateChanges.listen((AppUser? user) async {
      _user = user;

      // Identify user in Crashlytics
      if (user != null) {
        ObservabilityService.setUser(user.uid);
      } else {
        ObservabilityService.clearUser();
      }

      // Cold start / app recreated: check if TOTP is needed
      if (!_isLoggingIn && user != null && !_totpVerifiedThisSession) {
        try {
          final totpEnabled = await _totpRepository.isEnabled(user.uid);
          if (totpEnabled) {
            _pendingTotpVerification = true;
          }
        } catch (e) {
          debugPrint('TOTP cold-start check failed: $e');
        }
      }

      if (!_isLoggingIn) {
        notifyListeners();
      }
    });
  }

  Future<bool> login(String email, String password) async {
    final trace = await ObservabilityService.startTrace('login');
    try {
      _isLoading = true;
      _errorMessage = null;
      _pendingTotpVerification = false;
      _totpVerifiedThisSession = false;
      _isLoggingIn = true;
      notifyListeners();

      await _repository.signIn(email: email, password: password);

      _user = _repository.currentUser;

      if (_user != null) {
        try {
          final totpEnabled = await _totpRepository.isEnabled(_user!.uid);
          if (totpEnabled) {
            _pendingTotpVerification = true;
          }
        } catch (e) {
          debugPrint('TOTP check failed: $e');
        }
      }

      _isLoggingIn = false;
      _isLoading = false;
      await ObservabilityService.stopTrace(trace);
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoggingIn = false;
      _isLoading = false;
      _errorMessage = e.message;
      await ObservabilityService.stopTrace(trace);
      ObservabilityService.recordError(
        e,
        StackTrace.current,
        reason: 'login_auth_error',
      );
      notifyListeners();
      return false;
    } catch (e) {
      _isLoggingIn = false;
      _isLoading = false;
      _errorMessage = 'Erro ao fazer login. Tente novamente.';
      await ObservabilityService.stopTrace(trace);
      ObservabilityService.recordError(
        e,
        StackTrace.current,
        reason: 'login_unknown_error',
      );
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, {String? name}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.register(email: email, password: password);

      if (name != null && name.isNotEmpty) {
        await _repository.updateDisplayName(name);
        _user = _repository.currentUser;
      }

      await _repository.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao criar conta. Tente novamente.';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    _user = null;
    _pendingTotpVerification = false;
    _totpVerifiedThisSession = false;
    ObservabilityService.clearUser();
    notifyListeners();
  }

  Future<bool> updateName(String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.updateDisplayName(name);
      _user = _repository.currentUser;

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao atualizar nome.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.reauthenticate(currentPassword);
      await _repository.updatePassword(newPassword);

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao alterar senha.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendVerificationEmail() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.sendEmailVerification();

      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _isLoading = false;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao enviar email de verificação.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> refreshUser() async {
    try {
      await _repository.reloadUser();
      _user = _repository.currentUser;
      notifyListeners();
      return _user?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }

  void markPendingTotp() {
    _pendingTotpVerification = true;
    notifyListeners();
  }

  void completeTotpVerification() {
    _pendingTotpVerification = false;
    _totpVerifiedThisSession = true;
    notifyListeners();
  }
}
