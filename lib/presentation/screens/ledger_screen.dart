import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/empty_state.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/widgets/person_form.dart';
import 'package:aldeewan_mobile/presentation/widgets/transaction_form.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/presentation/widgets/debounced_search_bar.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';

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
      if (action == 'debt' || action == 'payment' || action == 'scan') {
        _initialActionHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleQuickAction(action!);
        });
      }
    }
  }

  void _handleQuickAction(String action) {
    final l10n = AppLocalizations.of(context)!;
    final ledgerAsync = ref.read(ledgerProvider);
    final persons = ledgerAsync.value?.persons ?? [];

    double? initialAmount;
    DateTime? initialDate;
    String? initialNote;

    if (action == 'scan') {
      final uri = GoRouterState.of(context).uri;
      if (uri.queryParameters.containsKey('amount')) {
        initialAmount = double.tryParse(uri.queryParameters['amount']!);
      }
      if (uri.queryParameters.containsKey('date')) {
        initialDate = DateTime.tryParse(uri.queryParameters['date']!);
      }
      initialNote = uri.queryParameters['note'];
    }

    if (persons.isEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24.0),
          width: double.infinity,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.users, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                l10n.noPersonsFound,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.addPersonPrompt,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddPersonModal(context);
                },
                icon: const Icon(LucideIcons.userPlus),
                label: Text(l10n.addPerson),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
      return;
    }

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
                // Re-watch in case it changes while open (unlikely but good practice)
                final ledgerAsync = ref.watch(ledgerProvider);
                final currentPersons = ledgerAsync.value?.persons ?? [];
                return ListView.builder(
                  itemCount: currentPersons.length,
                  itemBuilder: (context, index) {
                    final person = currentPersons[index];
                    return ListTile(
                      title: Text(person.name),
                      subtitle: Text(person.role == PersonRole.customer ? l10n.customer : l10n.supplier),
                      onTap: () {
                        Navigator.pop(context); // Close selector
                        _showTransactionModal(
                          person,
                          action,
                          initialAmount: initialAmount,
                          initialDate: initialDate,
                          initialNote: initialNote,
                        );
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

  void _showTransactionModal(
    Person person,
    String action, {
    double? initialAmount,
    DateTime? initialDate,
    String? initialNote,
  }) {
    TransactionType type;
    if (action == 'debt') {
      type = person.role == PersonRole.customer
          ? TransactionType.saleOnCredit
          : TransactionType.purchaseOnCredit;
    } else if (action == 'payment') {
      type = person.role == PersonRole.customer
          ? TransactionType.paymentReceived
          : TransactionType.paymentMade;
    } else {
      // Default for scan or other actions
      type = person.role == PersonRole.customer
          ? TransactionType.saleOnCredit
          : TransactionType.purchaseOnCredit;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TransactionForm(
        personId: person.id,
        personRole: person.role,
        initialType: type,
        initialAmount: initialAmount,
        initialDate: initialDate,
        initialNote: initialNote,
        onSave: (transaction) {
          ref.read(soundServiceProvider).playSuccess();
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
          ref.read(soundServiceProvider).playSuccess();
          ref.read(ledgerProvider.notifier).addPerson(person);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);
    final notifier = ref.read(ledgerProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ledger),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: [
                Tab(text: l10n.customer),
                Tab(text: l10n.supplier),
              ],
            ),
          ),
        ),
      ),
      body: ledgerAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text(l10n.errorOccurred(e.toString()))),
        data: (ledgerState) => TabBarView(
          controller: _tabController,
          children: [
            _buildPersonList(context, ledgerState.persons, PersonRole.customer, notifier, l10n, currency),
            _buildPersonList(context, ledgerState.persons, PersonRole.supplier, notifier, l10n, currency),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonModal(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPersonList(BuildContext context, List<Person> persons, PersonRole role, LedgerNotifier notifier, AppLocalizations l10n, String currency) {
    final searchQuery = ref.watch(ledgerSearchProvider);
    
    // Filter by role first, then by search query
    var filteredPersons = persons.where((p) => p.role == role).toList();
    
    if (searchQuery.isNotEmpty) {
      filteredPersons = filteredPersons.where((p) {
        final name = p.name.toLowerCase();
        final phone = (p.phone ?? '').toLowerCase();
        return name.contains(searchQuery) || phone.contains(searchQuery);
      }).toList();
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: DebouncedSearchBar(
            hintText: l10n.search,
            onSearch: (query) {
              ref.read(ledgerSearchProvider.notifier).state = query;
            },
          ),
        ),
        // Person balance tip
        const PersonBalanceTip(),
        // List or empty state
        Expanded(
          child: filteredPersons.isEmpty
              ? EmptyState(
                  message: searchQuery.isEmpty ? l10n.noEntriesYet : l10n.noResults,
                  icon: LucideIcons.users,
                  lottieAsset: 'assets/animations/empty_users.json',
                  actionLabel: searchQuery.isEmpty ? l10n.addPerson : null,
                  onAction: searchQuery.isEmpty ? () => _showAddPersonModal(context) : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 0, bottom: 80),
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
          balanceColor = isAsset ? AppColors.success : (isLiability ? AppColors.error : Colors.grey);
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
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                person.name.isNotEmpty ? person.name[0].toUpperCase() : '?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              person.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: person.phone != null && person.phone!.isNotEmpty
                ? Row(
                    children: [
                      Icon(LucideIcons.phone, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        person.phone!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  )
                : null,
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(
                    symbol: currency,
                    decimalDigits: currency == 'SDG' ? 0 : 2,
                  ).format(balance.abs()),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: balanceColor,
                  ),
                ),
                Text(
                  balance == 0 
                      ? l10n.settled 
                      : (role == PersonRole.customer 
                          ? (balance > 0 ? l10n.receivable : l10n.advance) 
                          : (balance > 0 ? l10n.payable : l10n.advance)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
    ),
        ),
      ],
    );
  }
}
