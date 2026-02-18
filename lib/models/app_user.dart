class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;
  final String? photoUrl;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.emailVerified = false,
    this.photoUrl,
  });
}
