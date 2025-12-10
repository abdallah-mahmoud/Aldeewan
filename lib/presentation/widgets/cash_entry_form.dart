import 'package:flutter/material.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';

class CashEntryForm extends StatefulWidget {
  final Function(Transaction) onSave;

  const CashEntryForm({super.key, required this.onSave});

  @override
  State<CashEntryForm> createState() => _CashEntryFormState();
}

class _CashEntryFormState extends State<CashEntryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  TransactionType _type = TransactionType.cashSale;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _noteController = TextEditingController();
    _date = DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
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

  void _save(AppLocalizations l10n) {
    if (_formKey.currentState!.validate()) {
      final amount = double.tryParse(_amountController.text);
      if (amount == null) return;

      final transaction = Transaction(
        id: const Uuid().v4(),
        type: _type,
        personId: null,
        amount: amount,
        date: _date,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      );
      widget.onSave(transaction);
      ToastService.showSuccess(context, l10n.savedSuccessfully);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
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
              value: _type,
              decoration: InputDecoration(
                labelText: l10n.type,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: TransactionType.cashSale,
                  child: Text(l10n.income), // Using generic Income for now, or add specific keys
                ),
                DropdownMenuItem(
                  value: TransactionType.cashIncome,
                  child: Text(l10n.income),
                ),
                DropdownMenuItem(
                  value: TransactionType.cashExpense,
                  child: Text(l10n.expense),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
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
                prefixText: '\$ ', // Should be localized currency symbol ideally
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterAmount;
                }
                if (double.tryParse(value) == null) {
                  return l10n.invalidNumber;
                }
                return null;
              },
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
    );
  }
}
