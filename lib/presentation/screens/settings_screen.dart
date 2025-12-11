import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:aldeewan_mobile/domain/entities/transaction.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/theme_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/locale_provider.dart';
import 'package:aldeewan_mobile/utils/csv_exporter.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/currency_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final currency = ref.watch(currencyProvider);
    final isAppLockEnabled = ref.watch(securityProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, l10n.appearance),
          ListTile(
            leading: const Icon(LucideIcons.sun),
            title: Text(l10n.theme),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              underline: const SizedBox(),
              onChanged: (ThemeMode? newValue) {
                if (newValue != null) {
                  ref.read(themeProvider.notifier).setTheme(newValue);
                }
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.system),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.light),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.dark),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.language),
          ListTile(
            leading: const Icon(LucideIcons.languages),
            title: Text(l10n.language),
            trailing: DropdownButton<Locale>(
              value: locale,
              underline: const SizedBox(),
              onChanged: (Locale? newValue) {
                if (newValue != null) {
                  ref.read(localeProvider.notifier).setLocale(newValue);
                }
              },
              items: const [
                DropdownMenuItem(
                  value: Locale('en'),
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: Locale('ar'),
                  child: Text('العربية'),
                ),
              ],
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.currencyOptions),
          ListTile(
            leading: const Icon(LucideIcons.banknote),
            title: Text(l10n.currency),
            trailing: DropdownButton<String>(
              value: currency,
              underline: const SizedBox(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(currencyProvider.notifier).setCurrency(newValue);
                }
              },
              items: const [
                DropdownMenuItem(value: 'QAR', child: Text('QAR (ر.ق)')),
                DropdownMenuItem(value: 'SAR', child: Text('SAR (ر.س)')),
                DropdownMenuItem(value: 'EGP', child: Text('EGP (ج.م)')),
                DropdownMenuItem(value: 'SDG', child: Text('SDG (ج.س)')),
              ],
            ),
          ),
          const Divider(),
          _buildSectionHeader(context, 'Security'),
          SwitchListTile(
            secondary: const Icon(LucideIcons.lock),
            title: const Text('App Lock'),
            subtitle: const Text('Require authentication to open app'),
            value: isAppLockEnabled,
            onChanged: (bool value) {
              ref.read(securityProvider.notifier).setAppLock(value);
            },
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.dataManagement),
          ListTile(
            leading: const Icon(LucideIcons.download),
            title: Text(l10n.backupData),
            subtitle: Text(l10n.backupDataSubtitle),
            onTap: () => _backupData(context, ref),
          ),
          ListTile(
            leading: const Icon(LucideIcons.upload),
            title: Text(l10n.restoreData),
            subtitle: Text(l10n.restoreDataSubtitle),
            onTap: () => _restoreData(context, ref),
          ),
          ListTile(
            leading: const Icon(LucideIcons.fileSpreadsheet),
            title: Text(l10n.exportPersons),
            onTap: () => _exportPersonsCsv(context, ref),
          ),
          ListTile(
            leading: const Icon(LucideIcons.fileText),
            title: Text(l10n.exportTransactions),
            onTap: () => _exportTransactionsCsv(context, ref),
          ),
          const Divider(),
          _buildSectionHeader(context, l10n.aboutDeveloper),
          ListTile(
            leading: const Icon(LucideIcons.info),
            title: Text(l10n.aboutDeveloper),
            trailing: const Icon(LucideIcons.chevronRight),
            onTap: () => context.go('/settings/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final persons = ref.read(ledgerProvider).persons;
      final transactions = ref.read(ledgerProvider).transactions;

      final data = {
        'persons': persons.map((p) => {
          'id': p.id,
          'role': p.role.toString().split('.').last,
          'name': p.name,
          'phone': p.phone,
          'createdAt': p.createdAt.toIso8601String(),
        }).toList(),
        'transactions': transactions.map((t) => {
          'id': t.id,
          'type': t.type.toString().split('.').last,
          'personId': t.personId,
          'amount': t.amount,
          'date': t.date.toIso8601String(),
          'category': t.category,
          'note': t.note,
          'dueDate': t.dueDate?.toIso8601String(),
        }).toList(),
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(data);
      final fileName = 'aldeewan_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
      
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(jsonString);

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Aldeewan Backup',
        text: l10n.backupSuccess,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.backupFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final data = jsonDecode(jsonString);

        if (data['version'] != 1) {
          throw Exception('Unsupported backup version');
        }

        final persons = (data['persons'] as List).map((p) => Person(
          id: p['id'],
          role: PersonRole.values.firstWhere((e) => e.toString().split('.').last == p['role']),
          name: p['name'],
          phone: p['phone'],
          createdAt: DateTime.parse(p['createdAt']),
        )).toList();

        final transactions = (data['transactions'] as List).map((t) => Transaction(
          id: t['id'],
          type: TransactionType.values.firstWhere((e) => e.toString().split('.').last == t['type']),
          personId: t['personId'],
          amount: (t['amount'] as num).toDouble(),
          date: DateTime.parse(t['date']),
          category: t['category'],
          note: t['note'],
          dueDate: t['dueDate'] != null ? DateTime.parse(t['dueDate']) : null,
        )).toList();

        // Warning: This replaces all data!
        // Ideally we should have a confirmation dialog here.
        // For now, we'll just proceed as per requirements (simple migration).
        
        // We need a method in LedgerNotifier to replace all data
        // But LedgerNotifier currently only adds/deletes.
        // We should probably expose the repository or add a bulk import method.
        // For now, let's iterate and add (this is slow but safe if we clear first).
        // But we can't clear easily without a clear method.
        
        // Let's assume for now we just add them (which might duplicate if IDs match, or update).
        // Realm put updates if ID matches.
        
        final notifier = ref.read(ledgerProvider.notifier);
        
        // TODO: Implement bulk import or clear & import in LedgerNotifier/Repository
        // For this MVP, we will just loop.
        for (var p in persons) {
          await notifier.addPerson(p);
        }
        for (var t in transactions) {
          await notifier.addTransaction(t);
        }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreSuccess)),
        );
      }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.restoreFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _exportPersonsCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final persons = ref.read(ledgerProvider).persons;
    final rows = <List<dynamic>>[
      ['ID', 'Name', 'Role', 'Phone', 'Created At'],
    ];

    for (var p in persons) {
      rows.add([
        p.id,
        p.name,
        p.role.toString().split('.').last,
        p.phone ?? '',
        DateFormat('yyyy-MM-dd HH:mm').format(p.createdAt),
      ]);
    }

    final fileName = 'persons_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await CsvExporter.exportToCsv(
      fileName: fileName,
      rows: rows,
      subject: 'Aldeewan Persons Export',
      text: l10n.exportPersons,
    );
  }

  Future<void> _exportTransactionsCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final transactions = ref.read(ledgerProvider).transactions;
    final persons = ref.read(ledgerProvider).persons;
    final personMap = {for (var p in persons) p.id: p.name};

    final rows = <List<dynamic>>[
      ['Date', 'Type', 'Person', 'Amount', 'Note', 'Category'],
    ];

    for (var t in transactions) {
      rows.add([
        DateFormat('yyyy-MM-dd').format(t.date),
        t.type.toString().split('.').last,
        t.personId != null ? (personMap[t.personId] ?? 'Unknown') : '',
        t.amount.toStringAsFixed(2),
        t.note ?? '',
        t.category ?? '',
      ]);
    }

    final fileName = 'transactions_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';
    await CsvExporter.exportToCsv(
      fileName: fileName,
      rows: rows,
      subject: 'Aldeewan Transactions Export',
      text: l10n.exportTransactions,
    );
  }
}
