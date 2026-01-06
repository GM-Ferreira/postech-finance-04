import '../models/monthly_data.dart';
import '../models/transaction.dart';

extension TransactionStats on List<Transaction> {
  Map<String, double> get summary {
    double income = 0;
    double expense = 0;

    for (final t in this) {
      if (t.isIncome) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return {'income': income, 'expense': expense, 'balance': income - expense};
  }

  Map<String, double> get categoryBreakdown {
    final Map<String, double> data = {};

    for (final t in this) {
      if (t.isExpense) {
        data[t.category] = (data[t.category] ?? 0) + t.amount;
      }
    }

    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sorted.take(6));
  }

  List<MonthlyData> get monthlyBreakdown {
    final now = DateTime.now();
    final List<MonthlyData> data = [];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      double income = 0;
      double expense = 0;

      for (final t in this) {
        if (t.date.year == month.year && t.date.month == month.month) {
          if (t.isIncome) {
            income += t.amount;
          } else {
            expense += t.amount;
          }
        }
      }

      data.add(
        MonthlyData(
          month: _getMonthAbbreviation(month.month),
          income: income,
          expense: expense,
        ),
      );
    }

    return data;
  }

  double get totalIncome {
    return where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return where((t) => t.isExpense).fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;
}

String _getMonthAbbreviation(int month) {
  const months = [
    'Jan',
    'Fev',
    'Mar',
    'Abr',
    'Mai',
    'Jun',
    'Jul',
    'Ago',
    'Set',
    'Out',
    'Nov',
    'Dez',
  ];
  return months[month - 1];
}
