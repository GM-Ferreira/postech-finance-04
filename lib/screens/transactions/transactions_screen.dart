import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/category.dart';
import '../../models/transaction.dart' as models;
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/custom_filter_chip.dart';
import '../../widgets/common/receipt_viewer.dart';
import '../../widgets/transactions/transaction_card.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _selectedType;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  bool get _hasActiveFilters =>
      _selectedType != null ||
      _selectedCategory != null ||
      _startDate != null ||
      _endDate != null;

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return 'Período';

    final start =
        '${_startDate!.day.toString().padLeft(2, '0')}/${_startDate!.month.toString().padLeft(2, '0')}';
    final end =
        '${_endDate!.day.toString().padLeft(2, '0')}/${_endDate!.month.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final transactionProvider = context.watch<TransactionProvider>();
    final userId = authProvider.user?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transações'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilters,
              tooltip: 'Limpar filtros',
            ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('Usuário não autenticado'))
          : Column(
              children: [
                _buildFilterBar(),

                Expanded(
                  child: StreamBuilder<List<models.Transaction>>(
                    stream: transactionProvider.getFilteredTransactions(
                      userId: userId,
                      type: _selectedType,
                      category: _selectedCategory,
                      startDate: _startDate,
                      endDate: _endDate,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primaryGreen,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Erro: ${snapshot.error}',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      final transactions = snapshot.data ?? [];
                      if (transactions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _hasActiveFilters
                                    ? Icons.search_off
                                    : Icons.receipt_long_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                _hasActiveFilters
                                    ? 'Nenhuma transação encontrada'
                                    : 'Nenhuma transação ainda',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                _hasActiveFilters
                                    ? 'Tente alterar os filtros'
                                    : 'Toque no + para adicionar',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          final transaction = transactions[index];
                          return TransactionCard(
                            transaction: transaction,
                            onDelete: () => _confirmDelete(
                              context,
                              transactionProvider,
                              transaction,
                            ),
                            onEdit: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TransactionFormScreen(
                                    transaction: transaction,
                                  ),
                                ),
                              );
                            },
                            onViewReceipt: transaction.receiptUrl != null
                                ? () => ReceiptViewer.show(
                                    context,
                                    url: transaction.receiptUrl,
                                  )
                                : null,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        backgroundColor: AppTheme.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          CustomFilterChip(
            label: _selectedType == null
                ? 'Tipo'
                : _selectedType == 'income'
                ? 'Receitas'
                : 'Despesas',
            isActive: _selectedType != null,
            onTap: () => _showTypeFilter(),
          ),

          const SizedBox(width: 8),

          CustomFilterChip(
            label: _selectedCategory ?? 'Categoria',
            isActive: _selectedCategory != null,
            onTap: () => _showCategoryFilter(),
          ),

          const SizedBox(width: 8),

          CustomFilterChip(
            label: _formatDateRange(),
            isActive: _startDate != null,
            onTap: _selectDateRange,
          ),
        ],
      ),
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Todos'),
              leading: const Icon(Icons.swap_vert),
              selected: _selectedType == null,
              onTap: () {
                setState(() => _selectedType = null);
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: const Text('Receitas'),
              leading: const Icon(Icons.arrow_upward, color: Colors.green),
              selected: _selectedType == 'income',
              onTap: () {
                setState(() => _selectedType = 'income');
                Navigator.pop(context);
              },
            ),

            ListTile(
              title: const Text('Despesas'),
              leading: const Icon(Icons.arrow_downward, color: Colors.red),
              selected: _selectedType == 'expense',
              onTap: () {
                setState(() => _selectedType = 'expense');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Todas'),
              leading: const Icon(Icons.category),
              selected: _selectedCategory == null,
              onTap: () {
                setState(() => _selectedCategory = null);
                Navigator.pop(context);
              },
            ),
            ...TransactionCategory.all.map(
              (category) => ListTile(
                title: Text(category.label),
                selected: _selectedCategory == category.label,
                onTap: () {
                  setState(() => _selectedCategory = category.label);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TransactionProvider provider,
    models.Transaction transaction,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir transação'),
        content: Text('Deseja excluir "${transaction.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _handleDeleteConfirmed(ctx, provider, transaction),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDeleteConfirmed(
    BuildContext ctx,
    TransactionProvider provider,
    models.Transaction transaction,
  ) async {
    Navigator.pop(ctx);

    final success = await provider.deleteTransaction(transaction.id!);

    if (mounted && !success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erro ao excluir'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted && success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transação excluída com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
