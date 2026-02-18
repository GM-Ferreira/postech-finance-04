import 'dart:io';

abstract class IStorageRepository {
  Future<String> uploadReceipt({
    required File file,
    required String userId,
    required String transactionId,
  });

  Future<void> deleteReceipt(String url);
}
