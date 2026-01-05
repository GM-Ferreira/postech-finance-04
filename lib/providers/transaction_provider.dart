import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/transaction.dart' as models;

class TransactionProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'transactions';

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CollectionReference get _transactionsRef =>
      _firestore.collection(_collection);

  Stream<List<models.Transaction>> getTransactions(String userId) {
    return _transactionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => models.Transaction.fromFirestore(doc))
              .toList();
        });
  }

  Stream<List<models.Transaction>> getFilteredTransactions({
    required String userId,
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    Query query = _transactionsRef.where('userId', isEqualTo: userId);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (startDate != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      final endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      query = query.where(
        'date',
        isLessThanOrEqualTo: Timestamp.fromDate(endOfDay),
      );
    }

    query = query.orderBy('date', descending: true);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => models.Transaction.fromFirestore(doc))
          .toList();
    });
  }

  Future<bool> addTransaction(models.Transaction transaction) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _transactionsRef.add(transaction.toFirestore());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao adicionar transação: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTransaction(models.Transaction transaction) async {
    if (transaction.id == null) {
      _errorMessage = 'ID da transação não encontrado';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _transactionsRef
          .doc(transaction.id)
          .update(transaction.toFirestore());

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao atualizar transação: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _transactionsRef.doc(transactionId).delete();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Erro ao remover transação: $e';
      notifyListeners();
      return false;
    }
  }

  Future<models.Transaction?> getTransactionById(String transactionId) async {
    try {
      final doc = await _transactionsRef.doc(transactionId).get();

      if (doc.exists) {
        return models.Transaction.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _errorMessage = 'Erro ao buscar transação: $e';
      notifyListeners();
      return null;
    }
  }
}
