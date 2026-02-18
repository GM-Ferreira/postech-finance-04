import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:otp/otp.dart';

import 'i_totp_repository.dart';

class TotpRepository implements ITotpRepository {
  final FirebaseFirestore _firestore;
  final FlutterSecureStorage _secureStorage;

  TotpRepository({
    FirebaseFirestore? firestore,
    FlutterSecureStorage? secureStorage,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  String _storageKey(String userId) => 'totp_secret_$userId';

  String _generateRandomSecret() {
    const base32Chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final random = Random.secure();
    return List.generate(32, (_) => base32Chars[random.nextInt(32)]).join();
  }

  @override
  Future<String> generateSecret(String userId) async {
    final secret = _generateRandomSecret();
    await _secureStorage.write(key: _storageKey(userId), value: secret);
    return secret;
  }

  @override
  String getQrUri({
    required String secret,
    required String email,
    String issuer = 'Finance App',
  }) {
    return 'otpauth://totp/$issuer:$email?secret=$secret&issuer=$issuer&algorithm=SHA1&digits=6&period=30';
  }

  @override
  Future<bool> verifyCode({
    required String userId,
    required String code,
  }) async {
    final secret = await _secureStorage.read(key: _storageKey(userId));
    if (secret == null) return false;

    final now = DateTime.now().millisecondsSinceEpoch;
    final generatedCode = OTP.generateTOTPCodeString(
      secret,
      now,
      algorithm: Algorithm.SHA1,
      length: 6,
      interval: 30,
      isGoogle: true,
    );

    return code == generatedCode;
  }

  @override
  Future<void> enable(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).set({
        'totpEnabled': true,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('TotpRepository.enable error: $e');
      rethrow;
    }
  }

  @override
  Future<void> disable(String userId) async {
    await _secureStorage.delete(key: _storageKey(userId));
    try {
      await _firestore.collection('users').doc(userId).set({
        'totpEnabled': false,
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('TotpRepository.disable error: $e');
      rethrow;
    }
  }

  @override
  Future<bool> isEnabled(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;
      return doc.data()?['totpEnabled'] == true;
    } catch (e) {
      debugPrint('TotpRepository.isEnabled error: $e');
      return false;
    }
  }
}
