import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';

/// Dialog for confirming person deletion with different scenarios
class DeletePersonDialog extends ConsumerWidget {
  final String personId;
  final String personName;
  final VoidCallback onDeleted;

  const DeletePersonDialog({
    super.key,
    required this.personId,
    required this.personName,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(ledgerProvider.notifier);

    return FutureBuilder<PersonDeletionResult>(
      future: notifier.checkPersonDeletion(personId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return AlertDialog(
            content: const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final result = snapshot.data!;
        return _buildDialog(context, ref, l10n, result);
      },
    );
  }

  Widget _buildDialog(BuildContext context, WidgetRef ref, AppLocalizations l10n, PersonDeletionResult result) {
    final notifier = ref.read(ledgerProvider.notifier);

    switch (result.status) {
      case PersonDeletionStatus.canDelete:
        // No transactions, zero balance - simple delete
        return AlertDialog(
          title: Text(l10n.deletePerson),
          content: Text(l10n.deletePersonConfirm(personName)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await notifier.deletePerson(personId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.personDeleted)),
                  );
                  onDeleted();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.delete),
            ),
          ],
        );

      case PersonDeletionStatus.hasTransactions:
        // Has transactions but zero balance - archive or delete all
        return AlertDialog(
          title: Text(l10n.deletePerson),
          content: Text(l10n.deletePersonWithTransactions(personName, result.transactionCount)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await notifier.archivePerson(personId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.personArchived)),
                  );
                  onDeleted();
                }
              },
              child: Text(l10n.archive),
            ),
            TextButton(
              onPressed: () async {
                await notifier.deletePersonWithTransactions(personId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.personDeleted)),
                  );
                  onDeleted();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
              child: Text(l10n.deleteAll),
            ),
          ],
        );

      case PersonDeletionStatus.hasBalance:
        // Has non-zero balance - can only archive
        return AlertDialog(
          title: Text(l10n.deletePerson),
          content: Text(l10n.cannotDeleteWithBalance(
            personName,
            result.balance.abs().toStringAsFixed(2),
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                await notifier.archivePerson(personId);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.personArchived)),
                  );
                  onDeleted();
                }
              },
              child: Text(l10n.archive),
            ),
          ],
        );
    }
  }
}
