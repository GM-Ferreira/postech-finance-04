import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../extensions/transaction_extensions.dart';
import '../../models/transaction.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/app_drawer.dart';
import '../../widgets/dashboard/balance_card.dart';
import '../../widgets/dashboard/category_pie_chart.dart';
import '../../widgets/dashboard/monthly_bar_chart.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          // TODO: Remover após teste do Crashlytics
          IconButton(
            icon: const Icon(Icons.bug_report, color: Colors.yellow),
            tooltip: 'Testar Crashlytics',
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Testar Crashlytics'),
                  content: const Text('Escolha o tipo de teste:'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        FirebaseCrashlytics.instance.recordError(
                          Exception('Teste non-fatal error'),
                          StackTrace.current,
                          reason: 'teste_manual',
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Non-fatal enviado ao Crashlytics!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                      },
                      child: const Text('Non-fatal error'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        FirebaseCrashlytics.instance.crash();
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Crash (app fecha!)'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: DrawerPage.dashboard),
      body: _buildDashboardBody(context),
    );
  }

  Widget _buildDashboardBody(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      return const Center(child: Text('Usuário não autenticado'));
    }

    return StreamBuilder<List<Transaction>>(
      stream: transactionProvider.getTransactions(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primaryGreen),
          );
        }

        if (snapshot.hasError) {
          return Center(child: Text('Erro: ${snapshot.error}'));
        }

        final transactions = snapshot.data ?? [];

        if (transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bar_chart, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhuma transação encontrada',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Adicione transações para ver os gráficos',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        final summary = transactions.summary;
        final categoryData = transactions.categoryBreakdown;
        final monthlyData = transactions.monthlyBreakdown;

        return RefreshIndicator(
          color: AppTheme.primaryGreen,
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BalanceCard(
                  balance: summary['balance']!,
                  income: summary['income']!,
                  expense: summary['expense']!,
                ),

                const SizedBox(height: 24),

                if (categoryData.isNotEmpty) ...[
                  const Text(
                    'Despesas por Categoria',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CategoryPieChart(data: categoryData),
                  const SizedBox(height: 24),
                ],

                const Text(
                  'Evolução Mensal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                MonthlyBarChart(data: monthlyData),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
