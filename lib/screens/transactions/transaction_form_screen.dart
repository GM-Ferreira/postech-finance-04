import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/transaction.dart' as models;
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class TransactionFormScreen extends StatefulWidget {
  final models.Transaction? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  bool get isEditing => transaction != null;

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  String _transactionType = 'expense';
  String _selectedCategory = 'Outros';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  final List<String> _incomeCategories = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Presente',
    'Outros',
  ];

  final List<String> _expenseCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Roupas',
    'Outros',
  ];

  List<String> get _categories =>
      _transactionType == 'income' ? _incomeCategories : _expenseCategories;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    if (transaction != null) {
      _descriptionController.text = transaction.description;
      _amountController.text = transaction.amount.toStringAsFixed(2);
      _transactionType = transaction.type;
      _selectedCategory = transaction.category;
      _selectedDate = transaction.date;
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _selectedDate = picked;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.user?.uid;

    if (userId == null) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: usuário não autenticado'),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final cleanAmount = _amountController.text.replaceAll(',', '.');
    final amount = double.parse(cleanAmount);

    final transactionProvider = context.read<TransactionProvider>();
    bool success;

    if (widget.isEditing) {
      final updated = widget.transaction!.copyWith(
        description: _descriptionController.text.trim(),
        amount: amount,
        type: _transactionType,
        category: _selectedCategory,
        date: _selectedDate,
      );

      success = await transactionProvider.updateTransaction(updated);
    } else {
      final transaction = models.Transaction(
        userId: userId,
        description: _descriptionController.text.trim(),
        amount: amount,
        type: _transactionType,
        category: _selectedCategory,
        date: _selectedDate,
      );
      success = await transactionProvider.addTransaction(transaction);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isEditing
                ? 'Transação atualizada com sucesso!'
                : 'Transação salva com sucesso!',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(transactionProvider.errorMessage ?? 'Erro ao salvar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe uma descrição';
    }
    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Informe o valor';
    }

    final cleanValue = value.replaceAll(',', '.');
    final amount = double.tryParse(cleanValue);

    if (amount == null || amount <= 0) {
      return 'Informe um valor válido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar Transação' : 'Nova Transação'),
        backgroundColor: AppTheme.primaryGreen,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Tipo de transação',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: _TypeButton(
                        label: 'Receita',
                        icon: Icons.arrow_upward,
                        color: Colors.green,
                        isSelected: _transactionType == 'income',
                        onTap: () {
                          setState(() {
                            _transactionType = 'income';
                            _selectedCategory = 'Outros';
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _TypeButton(
                        label: 'Despesa',
                        icon: Icons.arrow_downward,
                        color: Colors.red,
                        isSelected: _transactionType == 'expense',
                        onTap: () {
                          setState(() {
                            _transactionType = 'expense';
                            _selectedCategory = 'Outros';
                          });
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descrição',
                  hintText: 'Ex: Salário, Mercado, Aluguel...',
                  validator: _validateDescription,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

                CustomTextField(
                  controller: _amountController,
                  label: 'Valor (R\$)',
                  hintText: '0,00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _validateAmount,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Categoria',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                ),

                const SizedBox(height: 16),

                const Text(
                  'Data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),

                const SizedBox(height: 8),

                InkWell(
                  onTap: _isLoading ? null : _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/'
                          '${_selectedDate.month.toString().padLeft(2, '0')}/'
                          '${_selectedDate.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // TODO: Adicionar campo de comprovante (anexo) no futuro
                const SizedBox(height: 16),

                CustomButton(
                  text: widget.isEditing ? 'Atualizar' : 'Salvar Transação',
                  onPressed: _handleSave,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
