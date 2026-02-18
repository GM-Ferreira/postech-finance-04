import 'transaction_type.dart';

const _undefined = Object();

class Transaction {
  final String? id;
  final String userId;
  final String description;
  final double amount;
  final TransactionType type;
  final String category;
  final DateTime date;
  final String? receiptUrl;
  final DateTime createdAt;

  Transaction({
    this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.receiptUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
  factory Transaction.fromMap(Map<String, dynamic> data, {String? id}) {
    return Transaction(
      id: id,
      userId: data['userId'] ?? '',
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      type: TransactionType.fromValue(data['type'] ?? 'expense'),
      category: data['category'] ?? 'Outros',
      date: data['date'] is DateTime
          ? data['date'] as DateTime
          : DateTime.parse(data['date'].toString()),
      receiptUrl: data['receiptUrl'],
      createdAt: data['createdAt'] is DateTime
          ? data['createdAt'] as DateTime
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'description': description,
      'amount': amount,
      'type': type.value,
      'category': category,
      'date': date,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt,
    };
  }

  Transaction copyWith({
    String? id,
    String? userId,
    String? description,
    double? amount,
    TransactionType? type,
    String? category,
    DateTime? date,
    Object? receiptUrl = _undefined,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      receiptUrl: receiptUrl == _undefined
          ? this.receiptUrl
          : receiptUrl as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isIncome => type.isIncome;

  bool get isExpense => type.isExpense;

  double get signedAmount => isIncome ? amount : -amount;

  @override
  String toString() {
    return 'Transaction(id: $id, description: $description, amount: $amount, type: ${type.value})';
  }
}
