import '../models/transaction.dart' as models;

abstract class ITransactionRepository {
  Stream<List<models.Transaction>> getTransactions(String userId);

  Stream<List<models.Transaction>> getFilteredTransactions({
    required String userId,
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<void> addTransaction(models.Transaction transaction);

  Future<void> updateTransaction(models.Transaction transaction);

  Future<void> deleteTransaction(String transactionId);

  Future<models.Transaction?> getTransactionById(String transactionId);
}
