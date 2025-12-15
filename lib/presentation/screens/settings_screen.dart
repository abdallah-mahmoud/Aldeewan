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
import 'package:aldeewan_mobile/utils/error_handler.dart';
import 'package:aldeewan_mobile/presentation/providers/settings_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/notification_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/sound_settings_provider.dart';

import 'package:aldeewan_mobile/presentation/screens/categories_management_screen.dart';
import 'package:aldeewan_mobile/presentation/widgets/settings/settings_section.dart';
import 'package:aldeewan_mobile/presentation/widgets/settings/settings_tile.dart';
import 'package:aldeewan_mobile/presentation/widgets/settings/theme_selector.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final currency = ref.watch(currencyProvider);
    final isAppLockEnabled = ref.watch(securityProvider);
    final isSimpleMode = ref.watch(settingsProvider);
    final isSoundEnabled = ref.watch(soundSettingsProvider);
    final notificationState = ref.watch(notificationProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: Text(l10n.settings),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // Appearance Section
            SettingsSection(
              title: l10n.appearance,
              children: [
                ThemeSelector(
                  currentMode: themeMode,
                  onThemeChanged: (mode) {
                    ref.read(themeProvider.notifier).setTheme(mode);
                  },
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.languages,
                  iconColor: Colors.purple,
                  title: l10n.language,
                  trailing: DropdownButton<Locale>(
                    value: locale,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    onChanged: (Locale? newValue) {
                      if (newValue != null) {
                        ref.read(localeProvider.notifier).setLocale(newValue);
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: const Locale('en'),
                        child: Text(l10n.english, style: theme.textTheme.bodyMedium),
                      ),
                      const DropdownMenuItem(
                        value: Locale('ar'),
                        child: Text('العربية'),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.layoutTemplate,
                  iconColor: Colors.orange,
                  title: l10n.simpleMode,
                  subtitle: l10n.simpleModeSubtitle,
                  trailing: Switch.adaptive(
                    value: isSimpleMode,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(settingsProvider.notifier).setSimpleMode(value);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.volume2,
                  iconColor: Colors.teal,
                  title: l10n.appSounds, // Need to add this to l10n
                  subtitle: l10n.appSoundsSubtitle, // Need to add this to l10n
                  trailing: Switch.adaptive(
                    value: isSoundEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(soundSettingsProvider.notifier).setSoundEnabled(value);
                    },
                  ),
                ),
              ],
            ),

            // Notifications Section
            SettingsSection(
              title: l10n.notifications,
              children: [
                SettingsTile(
                  icon: LucideIcons.bell,
                  iconColor: Colors.amber,
                  title: l10n.dailyReminder,
                  subtitle: l10n.dailyReminderSubtitle,
                  trailing: Switch.adaptive(
                    value: notificationState.isEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(notificationProvider.notifier).toggleReminder(
                        value,
                        l10n.dailyReminderTitle,
                        l10n.dailyReminderBody,
                      );
                    },
                  ),
                ),
                if (notificationState.isEnabled) ...[
                  const Divider(height: 1, indent: 60),
                  SettingsTile(
                    icon: LucideIcons.clock,
                    iconColor: Colors.blue,
                    title: l10n.reminderTime,
                    trailing: TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: notificationState.time,
                        );
                        if (picked != null) {
                          ref.read(notificationProvider.notifier).setTime(
                            picked,
                            l10n.dailyReminderTitle,
                            l10n.dailyReminderBody,
                          );
                        }
                      },
                      child: Text(
                        notificationState.time.format(context),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SettingsTile(
                    icon: LucideIcons.send,
                    iconColor: Colors.purple,
                    title: 'Test Notification', // Debug only
                    onTap: () async {
                      final hasPerms = await ref.read(notificationProvider.notifier).requestPermissions();
                      if (hasPerms) {
                        await ref.read(notificationProvider.notifier).showTestNotification(
                          l10n.dailyReminderTitle,
                          l10n.dailyReminderBody,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Test notification sent')),
                          );
                        }
                      } else {
                         if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Permissions denied')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ],
            ),

            // General Section
            SettingsSection(
              title: l10n.general,
              children: [
                SettingsTile(
                  icon: LucideIcons.banknote,
                  iconColor: Colors.green,
                  title: l10n.currency,
                  trailing: DropdownButton<String>(
                    value: currency,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        ref.read(currencyProvider.notifier).setCurrency(newValue);
                      }
                    },
                    items: [
                      DropdownMenuItem(value: 'QAR', child: Text(l10n.currencyQAR)),
                      DropdownMenuItem(value: 'SAR', child: Text(l10n.currencySAR)),
                      DropdownMenuItem(value: 'EGP', child: Text(l10n.currencyEGP)),
                      DropdownMenuItem(value: 'SDG', child: Text(l10n.currencySDG)),
                      DropdownMenuItem(value: 'KWD', child: Text(l10n.currencyKWD)),
                    ],
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.lock,
                  iconColor: Colors.blue,
                  title: l10n.appLock,
                  subtitle: l10n.appLockSubtitle,
                  trailing: Switch.adaptive(
                    value: isAppLockEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (bool value) {
                      ref.read(securityProvider.notifier).setAppLock(value);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.tags,
                  iconColor: Colors.indigo,
                  title: l10n.manageCategories,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CategoriesManagementScreen()),
                    );
                  },
                ),
              ],
            ),

            // Data Management Section
            SettingsSection(
              title: l10n.dataManagement,
              children: [
                SettingsTile(
                  icon: LucideIcons.download,
                  iconColor: Colors.teal,
                  title: l10n.backupData,
                  subtitle: l10n.backupDataSubtitle,
                  onTap: () => _backupData(context, ref),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.upload,
                  iconColor: Colors.amber,
                  title: l10n.restoreData,
                  subtitle: l10n.restoreDataSubtitle,
                  onTap: () => _restoreData(context, ref),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.fileSpreadsheet,
                  iconColor: Colors.greenAccent.shade700,
                  title: l10n.exportPersons,
                  onTap: () => _exportPersonsCsv(context, ref),
                ),
                const Divider(height: 1, indent: 60),
                SettingsTile(
                  icon: LucideIcons.fileText,
                  iconColor: Colors.blueAccent,
                  title: l10n.exportTransactions,
                  onTap: () => _exportTransactionsCsv(context, ref),
                ),
              ],
            ),

            SettingsSection(
              title: l10n.aboutDeveloper,
              children: [
                SettingsTile(
                  icon: LucideIcons.info,
                  iconColor: Colors.grey,
                  title: l10n.aboutDeveloper,
                  onTap: () => context.go('/settings/about'),
                ),
              ],
            ),

            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.appVersionInfo('2.0.0'),
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.madeWithLove,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _backupData(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final ledgerState = ref.read(ledgerProvider).value;
      final persons = ledgerState?.persons ?? [];
      final transactions = ledgerState?.transactions ?? [];

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
          SnackBar(content: Text(l10n.backupFailed(ErrorHandler.getUserFriendlyErrorMessage(e, l10n)))),
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
          SnackBar(content: Text(l10n.restoreFailed(ErrorHandler.getUserFriendlyErrorMessage(e, l10n)))),
        );
      }
    }
  }

  Future<void> _exportPersonsCsv(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final persons = ref.read(ledgerProvider).value?.persons ?? [];
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
    final ledgerState = ref.read(ledgerProvider).value;
    final transactions = ledgerState?.transactions ?? [];
    final persons = ledgerState?.persons ?? [];
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
