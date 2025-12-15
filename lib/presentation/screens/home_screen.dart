import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/accounts_section.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/dashboard_buttons.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/hero_section.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/quick_actions.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/recent_transactions.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/summary_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ledgerAsync = ref.watch(ledgerProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ledgerAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.errorOccurred(err.toString())))),
      data: (_) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Custom Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appName,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.tagline,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {
                          ref.read(soundServiceProvider).playClick();
                          context.push('/notifications');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Icon(LucideIcons.bell, color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Hero Section (Net Position + Range Filter)
                  const HeroSection(),
                  const SizedBox(height: 16),

                  // Budget & Goals Buttons
                  const DashboardButtons(),
                  const SizedBox(height: 24),

                  // Summary Stats Grid
                  const SummaryGrid(),
                  const SizedBox(height: 24),

                  // Quick Actions
                  const QuickActions(),
                  const SizedBox(height: 24),

                  // Recent Transactions
                  const RecentTransactions(),
                  const SizedBox(height: 32),

                  // Accounts Section
                  const AccountsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
