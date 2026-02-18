abstract class ITotpRepository {
  Future<String> generateSecret(String userId);

  String getQrUri({
    required String secret,
    required String email,
    String issuer = 'Finance App',
  });

  Future<bool> verifyCode({required String userId, required String code});

  Future<void> enable(String userId);

  Future<void> disable(String userId);

  Future<bool> isEnabled(String userId);
}
