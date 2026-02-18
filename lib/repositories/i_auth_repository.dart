import '../models/app_user.dart';

abstract class IAuthRepository {
  Stream<AppUser?> get authStateChanges;

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({required String email, required String password});

  Future<void> signOut();

  Future<void> updateDisplayName(String name);

  Future<void> reauthenticate(String password);

  Future<void> updatePassword(String newPassword);

  Future<void> sendEmailVerification();

  Future<void> reloadUser();
}
