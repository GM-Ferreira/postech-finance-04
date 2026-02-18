import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'i_storage_repository.dart';

class StorageRepository implements IStorageRepository {
  final FirebaseStorage _storage;

  StorageRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<String> uploadReceipt({
    required File file,
    required String userId,
    required String transactionId,
  }) async {
    try {
      final String fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$transactionId';

      final Reference ref = _storage.ref().child('receipts/$userId/$fileName');

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload do comprovante: $e');
    }
  }

  @override
  Future<void> deleteReceipt(String url) async {
    try {
      final Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar comprovante: $e');
      }
    }
  }
}
