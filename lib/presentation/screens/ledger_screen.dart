import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/transaction_form.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _initialActionHandled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialActionHandled) {
      final action = GoRouterState.of(context).uri.queryParameters['action'];
      if (action == 'debt' || action == 'payment') {
        _initialActionHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleQuickAction(action!);
        });
      }
    }
  }

  void _handleQuickAction(String action) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              l10n.selectPerson,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final persons = ref.watch(ledgerProvider).persons;
                return ListView.builder(
                  itemCount: persons.length,
                  itemBuilder: (context, index) {
                    final person = persons[index];
                    return ListTile(
                      title: Text(person.name),
                      subtitle: Text(person.role == PersonRole.customer ? l10n.customer : l10n.supplier),
                      onTap: () {
                        Navigator.pop(context); // Close selector
                        _showTransactionModal(person, action);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionModal(Person person, String action) {
    TransactionType type;
    if (action == 'debt') {
      type = person.role == PersonRole.customer 
          ? TransactionType.saleOnCredit 
          : TransactionType.purchaseOnCredit;
    } else {
      type = person.role == PersonRole.customer 
          ? TransactionType.paymentReceived 
          : TransactionType.paymentMade;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionForm(
        personId: person.id,
        initialType: type,
        onSave: (transaction) {
          ref.read(ledgerProvider.notifier).addTransaction(transaction);
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddPersonModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PersonForm(
        onSave: (person) {
          ref.read(ledgerProvider.notifier).addPerson(person);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerState = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ledger),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.customer),
            Tab(text: l10n.supplier),
          ],
        ),
      ),
      body: ledgerState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPersonList(context, ledgerState.persons, PersonRole.customer, notifier, l10n),
                _buildPersonList(context, ledgerState.persons, PersonRole.supplier, notifier, l10n),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPersonList(BuildContext context, List<Person> persons, PersonRole role, LedgerNotifier notifier, AppLocalizations l10n) {
    final filteredPersons = persons.where((p) => p.role == role).toList();

    if (filteredPersons.isEmpty) {
      return EmptyState(
        message: l10n.noEntriesYet,
        icon: LucideIcons.users,
        actionLabel: l10n.addPerson,
        onAction: () => _showAddPersonModal(context),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80), // Add padding for FAB
      itemCount: filteredPersons.length,
      itemBuilder: (context, index) {
        final person = filteredPersons[index];
        final balance = notifier.calculatePersonBalance(person);
        
        // Determine color based on role and balance
        // Customer: > 0 means they owe us (Asset -> Green)
        // Supplier: > 0 means we owe them (Liability -> Red)
        final isAsset = (role == PersonRole.customer && balance > 0) || 
                        (role == PersonRole.supplier && balance < 0);
        final isLiability = (role == PersonRole.supplier && balance > 0) || 
                            (role == PersonRole.customer && balance < 0);
        
        Color balanceColor = Theme.of(context).colorScheme.onSurface;
        if (balance != 0) {
          balanceColor = isAsset ? Colors.green : (isLiability ? Colors.red : Colors.grey);
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          elevation: 0,
          color: Theme.of(context).cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              child: Text(person.name.isNotEmpty ? person.name[0].toUpperCase() : '?'),
            ),
            title: Text(
              person.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: person.phone != null && person.phone!.isNotEmpty
                ? Row(
                    children: [
                      Icon(LucideIcons.phone, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(person.phone!),
                    ],
                  )
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance.abs().toStringAsFixed(2),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: balanceColor,
                  ),
                ),
                Text(
                  balance == 0 
                      ? 'Settled' 
                      : (role == PersonRole.customer 
                          ? (balance > 0 ? 'Receivable' : 'Advance') 
                          : (balance > 0 ? 'Payable' : 'Advance')),
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            onTap: () {
              context.push('/ledger/${person.id}');
            },
          ),
        );
      },
    );
  }
}
