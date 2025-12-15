import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/presentation/models/category.dart';
import 'package:aldeewan_mobile/presentation/widgets/category_selector.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/budget_provider.dart';
import 'package:aldeewan_mobile/data/models/budget_model.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_history_provider.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';

class CashEntryForm extends ConsumerStatefulWidget {
  final Function(Transaction) onSave;
  final double? initialAmount;
  final DateTime? initialDate;
  final String? initialNote;
  final String? initialCategory;
  final TransactionType? initialType;

  const CashEntryForm({
    super.key, 
    required this.onSave,
    this.initialAmount,
    this.initialDate,
    this.initialNote,
    this.initialCategory,
    this.initialType,
  });

  @override
  ConsumerState<CashEntryForm> createState() => _CashEntryFormState();
}

class _CashEntryFormState extends ConsumerState<CashEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late TransactionType _type;
  late DateTime _date;
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.initialAmount != null ? widget.initialAmount.toString() : ''
    );
    _noteController = TextEditingController(text: widget.initialNote ?? '');
    _date = widget.initialDate ?? DateTime.now();
    _type = widget.initialType ?? TransactionType.cashSale;
    
    if (widget.initialCategory != null) {
      // We need to find the category object from the name.
      // Since we don't have the list here easily without context/ref in initState (ref is available but provider might not be ready or we need to listen),
      // we can try to set it in didChangeDependencies or just use a helper if available.
      // Or we can just set the name and let the selector handle it? No, selector needs object.
      // Let's try to find it in didChangeDependencies or build.
      // Actually, we can use CategoryHelper to get icon/color if we just have name, but _selectedCategory is a Category object.
      // Let's defer this to didChangeDependencies.
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.initialCategory != null && _selectedCategory == null) {
       // This is a bit hacky, we construct a Category object from the name using helper defaults
       // Ideally we should fetch from CategoryProvider but that might be async or complex.
       // For now, let's create a temporary one so the UI shows something.
       _selectedCategory = Category(
         id: 'temp', // ID doesn't matter for display
         name: widget.initialCategory!,
         icon: CategoryHelper.getIcon(widget.initialCategory!),
         color: CategoryHelper.getColor(widget.initialCategory!),
         type: 'expense', // Assumption
       );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    ref.read(soundServiceProvider).playClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _date) {
      setState(() {
        _date = picked;
      });
    }
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text.replaceAll(',', ''));
      if (amount == null) return;

      // Check Budget Constraint
      if (_type == TransactionType.cashExpense && _selectedCategory != null) {
        final budgetState = ref.read(budgetProvider);
        final activeBudget = budgetState.budgets.cast<BudgetModel?>().firstWhere(
          (b) => b?.category == _selectedCategory!.name && 
                 _date.isAfter(b!.startDate.subtract(const Duration(days: 1))) && 
                 _date.isBefore(b.endDate.add(const Duration(days: 1))),
          orElse: () => null,
        );

        if (activeBudget != null) {
          if (activeBudget.currentSpent + amount > activeBudget.amountLimit) {
            final overrun = (activeBudget.currentSpent + amount) - activeBudget.amountLimit;
            final currency = ref.read(currencyProvider);
            final formatter = NumberFormat('#,##0.##');
            final formattedOverrun = formatter.format(overrun);

            // Show confirmation dialog instead of blocking
            final shouldProceed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(l10n.budgetExceededTitle),
                content: Text(l10n.budgetExceededBody(activeBudget.category, formattedOverrun, currency)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(l10n.cancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(l10n.save), // Or "Proceed"
                  ),
                ],
              ),
            );

            if (shouldProceed != true) return;

            // Add notification
            if (mounted) {
              ref.read(notificationHistoryProvider.notifier).addNotification(
                title: l10n.budgetExceededTitle,
                body: l10n.budgetExceededBody(activeBudget.category, formattedOverrun, currency),
                type: 'warning',
              );
            }
          }
        }
      }

      final transaction = Transaction(
        id: const Uuid().v4(),
        type: _type,
        personId: null,
        amount: amount,
        date: _date,
        category: _selectedCategory?.name,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      widget.onSave(transaction);
      if (mounted) {
        ref.read(soundServiceProvider).playMoneyIn();
        ToastService.showSuccess(context, l10n.savedSuccessfully);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Text(
              l10n.addCashEntry,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<TransactionType>(
              initialValue: _type,
              decoration: InputDecoration(
                labelText: l10n.type,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: TransactionType.cashSale,
                  child: Text(l10n.cashLabel),
                ),
                DropdownMenuItem(
                  value: TransactionType.cashIncome,
                  child: Text(l10n.bankLabel),
                ),
                DropdownMenuItem(
                  value: TransactionType.cashExpense,
                  child: Text(l10n.expense),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(soundServiceProvider).playClick();
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amountController,
              decoration: InputDecoration(
                labelText: l10n.amount,
                border: const OutlineInputBorder(),
                prefixText: '$currency ',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [ThousandsSeparatorInputFormatter(allowFraction: true)],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterAmount;
                }
                if (double.tryParse(value.replaceAll(',', '')) == null) {
                  return l10n.invalidNumber;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Determine filter type based on transaction type
                String? filterType;
                if (_type == TransactionType.cashIncome || _type == TransactionType.cashSale || _type == TransactionType.paymentReceived) {
                  filterType = 'income';
                } else if (_type == TransactionType.cashExpense || _type == TransactionType.paymentMade) {
                  filterType = 'expense';
                }

                showModalBottomSheet(
                  context: context,
                  builder: (context) => CategorySelector(
                    filterType: filterType,
                    onSelected: (category) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.category,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                ),
                child: Row(
                  children: [
                    if (_selectedCategory != null) ...[
                      Icon(_selectedCategory!.icon, color: _selectedCategory!.color, size: 20),
                      const SizedBox(width: 8),
                      Text(CategoryHelper.getLocalizedCategory(_selectedCategory!.name, l10n)),
                    ] else
                      Text(l10n.category, style: TextStyle(color: Theme.of(context).hintColor)),
                    const Spacer(),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.date,
                  border: const OutlineInputBorder(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMd().format(_date)),
                    const Icon(LucideIcons.calendar),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.note,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _save(l10n),
              child: Text(l10n.save),
            ),
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }
}
