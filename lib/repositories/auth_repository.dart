import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/auth_exception.dart';
import 'i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
      photoUrl: user.photoURL,
    );
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'user-disabled':
        return 'Usuário desabilitado.';
      case 'email-already-in-use':
        return 'Este email já está em uso.';
      case 'weak-password':
        return 'A senha é muito fraca.';
      case 'invalid-credential':
        return 'Email ou senha incorretos.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toAppUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return _toAppUser(credential.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Nenhum usuário logado.');
    try {
      await user.updateDisplayName(name.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Nenhum usuário logado.');
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Nenhum usuário logado.');
    try {
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Nenhum usuário logado.');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }

  @override
  Future<void> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) throw const AuthException('Nenhum usuário logado.');
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseError(e.code));
    }
  }
}
