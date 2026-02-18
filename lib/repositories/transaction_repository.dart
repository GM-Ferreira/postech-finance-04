import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction.dart' as models;
import 'i_transaction_repository.dart';

class TransactionRepository implements ITransactionRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'transactions';

  TransactionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _transactionsRef =>
      _firestore.collection(_collection);

  models.Transaction _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return models.Transaction.fromMap({
      ...data,
      'date': (data['date'] as Timestamp).toDate(),
      'createdAt':
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    }, id: doc.id);
  }

  Map<String, dynamic> _toFirestore(models.Transaction transaction) {
    final map = transaction.toMap();
    return {
      ...map,
      'date': Timestamp.fromDate(map['date'] as DateTime),
      'createdAt': Timestamp.fromDate(map['createdAt'] as DateTime),
    };
  }

  @override
  Stream<List<models.Transaction>> getTransactions(String userId) {
    return _transactionsRef
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_fromDoc).toList();
        });
  }

  @override
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
      return snapshot.docs.map(_fromDoc).toList();
    });
  }

  @override
  Future<void> addTransaction(models.Transaction transaction) async {
    await _transactionsRef.add(_toFirestore(transaction));
  }

  @override
  Future<void> updateTransaction(models.Transaction transaction) async {
    if (transaction.id == null) {
      throw ArgumentError('ID da transação não encontrado');
    }
    await _transactionsRef
        .doc(transaction.id)
        .update(_toFirestore(transaction));
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    await _transactionsRef.doc(transactionId).delete();
  }

  @override
  Future<models.Transaction?> getTransactionById(String transactionId) async {
    final doc = await _transactionsRef.doc(transactionId).get();
    if (doc.exists) {
      return _fromDoc(doc);
    }
    return null;
  }
}
