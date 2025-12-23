import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/ledger_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/accounts_section.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/dashboard_buttons.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/hero_section.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/quick_actions.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/recent_transactions.dart';
import 'package:aldeewan_mobile/presentation/widgets/home/summary_grid.dart';
import 'package:aldeewan_mobile/presentation/widgets/showcase_wrapper.dart';
import 'package:aldeewan_mobile/presentation/widgets/tip_card.dart';
import 'package:aldeewan_mobile/presentation/widgets/initial_balance_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with ShowcaseTourMixin {
  bool _hasCheckedInitialBalance = false;
  
  @override
  List<GlobalKey> get showcaseKeys => ShowcaseKeys.homeKeys;
  
  @override
  String get screenTourId => 'home';
  
  void _checkInitialBalancePrompt() async {
    if (_hasCheckedInitialBalance) return;
    _hasCheckedInitialBalance = true;
    
    final onboarding = ref.read(onboardingServiceProvider);
    
    // Step 1: Show initial balance dialog if not shown
    if (!onboarding.isInitialBalancePromptShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        await showDialog<bool>(
          context: context,
          barrierDismissible: false, // Force user action to prevent conflict with tour
          builder: (_) => const InitialBalanceDialog(),
        );
        
        // Mark as shown after dialog completes
        await onboarding.markInitialBalancePromptShown();
        
        // Step 2: Start tour AFTER dialog closes
        if (!onboarding.isTourCompleted && mounted) {
          // Short delay to ensure dialog is fully dismissed
          await Future.delayed(const Duration(milliseconds: 300));
          if (mounted) startTourIfNeeded();
        }
      });
    } else if (!onboarding.isTourCompleted) {
      // If balance already shown but tour not done, start tour
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) startTourIfNeeded();
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final ledgerAsync = ref.watch(ledgerProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return ledgerAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text(AppLocalizations.of(context)!.errorOccurred(err.toString())))),
      data: (_) {
        // Check for initial balance prompt on first load
        _checkInitialBalancePrompt();
        
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
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
                            SizedBox(height: 4.h),
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
                      SizedBox(width: 16.w),
                      InkWell(
                        onTap: () {
                          ref.read(soundServiceProvider).playClick();
                          context.push('/notifications');
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                          ),
                          child: Icon(LucideIcons.bell, color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Hero Section (Net Position + Range Filter) - Tour Target
                  ShowcaseTarget(
                    showcaseKey: ShowcaseKeys.dashboardCards,
                    title: l10n.tourWelcome,
                    description: l10n.tourDashboard,
                    child: const HeroSection(),
                  ),
                  SizedBox(height: 16.h),

                  // Budget & Goals Buttons
                  const DashboardButtons(),
                  SizedBox(height: 24.h),

                  // Summary Stats Grid
                  const SummaryGrid(),
                  SizedBox(height: 24.h),

                  // Quick Actions - Tour Target Step 2
                  ShowcaseTarget(
                    showcaseKey: ShowcaseKeys.quickActions,
                    title: l10n.tourWelcome,
                    description: l10n.tourAddTransaction,
                    child: const QuickActions(),
                  ),
                  SizedBox(height: 8.h),
                  
                  // Tip Card for Quick Actions
                  const QuickActionsTip(),
                  SizedBox(height: 24.h),

                  // Recent Transactions
                  const RecentTransactions(),
                  SizedBox(height: 32.h),

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
