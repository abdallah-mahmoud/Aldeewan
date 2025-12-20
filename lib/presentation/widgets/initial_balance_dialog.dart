import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/input_formatters.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';

/// Dialog shown on first app launch to capture user's initial cash/bank balance
class InitialBalanceDialog extends ConsumerStatefulWidget {
  const InitialBalanceDialog({super.key});

  @override
  ConsumerState<InitialBalanceDialog> createState() => _InitialBalanceDialogState();
}

class _InitialBalanceDialogState extends ConsumerState<InitialBalanceDialog> {
  final _formKey = GlobalKey<FormState>();
  final _cashController = TextEditingController();
  final _bankController = TextEditingController();

  @override
  void dispose() {
    _cashController.dispose();
    _bankController.dispose();
    super.dispose();
  }

  Future<void> _save(AppLocalizations l10n) async {
    // Mark as shown first
    await ref.read(onboardingServiceProvider).markInitialBalancePromptShown();
    
    final cashAmount = double.tryParse(_cashController.text.replaceAll(',', '')) ?? 0;
    final bankAmount = double.tryParse(_bankController.text.replaceAll(',', '')) ?? 0;
    
    // Only create transactions if amounts are provided
    if (cashAmount > 0) {
      final cashTransaction = Transaction(
        id: const Uuid().v4(),
        type: TransactionType.cashSale,
        personId: null,
        amount: cashAmount,
        date: DateTime.now(),
        category: null,
        note: l10n.initialBalanceNote,
      );
      ref.read(ledgerProvider.notifier).addTransaction(cashTransaction);
    }
    
    if (bankAmount > 0) {
      final bankTransaction = Transaction(
        id: const Uuid().v4(),
        type: TransactionType.cashIncome,
        personId: null,
        amount: bankAmount,
        date: DateTime.now(),
        category: null,
        note: l10n.initialBalanceNote,
      );
      ref.read(ledgerProvider.notifier).addTransaction(bankTransaction);
    }
    
    if ((cashAmount > 0 || bankAmount > 0) && mounted) {
      ref.read(soundServiceProvider).playSuccess();
    }
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _skip() async {
    await ref.read(onboardingServiceProvider).markInitialBalancePromptShown();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currency = ref.watch(currencyProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          LucideIcons.wallet,
          size: 32,
          color: theme.colorScheme.primary,
        ),
      ),
      title: Text(
        l10n.initialBalanceTitle,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.initialBalanceDescription,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              // Cash on Hand field
              TextFormField(
                controller: _cashController,
                decoration: InputDecoration(
                  labelText: l10n.cashOnHand,
                  prefixText: '$currency ',
                  prefixIcon: Icon(LucideIcons.banknote, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
              ),
              const SizedBox(height: 16),
              // Bank Balance field
              TextFormField(
                controller: _bankController,
                decoration: InputDecoration(
                  labelText: l10n.bankBalance,
                  prefixText: '$currency ',
                  prefixIcon: Icon(LucideIcons.landmark, color: theme.colorScheme.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: amountFormatters(allowFraction: true),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton(
              onPressed: () => _save(l10n),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.letsGo),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _skip,
              child: Text(l10n.skipForNow),
            ),
          ],
        ),
      ],
    );
  }
}
