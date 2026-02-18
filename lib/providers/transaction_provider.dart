import 'package:flutter/material.dart';

import '../models/transaction.dart' as models;
import '../repositories/i_transaction_repository.dart';

class TransactionProvider extends ChangeNotifier {
  final ITransactionRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  TransactionProvider({required ITransactionRepository repository})
    : _repository = repository;

  Stream<List<models.Transaction>> getTransactions(String userId) {
    return _repository.getTransactions(userId);
  }

  Stream<List<models.Transaction>> getFilteredTransactions({
    required String userId,
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _repository.getFilteredTransactions(
      userId: userId,
      type: type,
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<bool> addTransaction(models.Transaction transaction) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.addTransaction(transaction);

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
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.updateTransaction(transaction);

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

      await _repository.deleteTransaction(transactionId);

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
      return await _repository.getTransactionById(transactionId);
    } catch (e) {
      _errorMessage = 'Erro ao buscar transação: $e';
      notifyListeners();
      return null;
    }
  }
}
