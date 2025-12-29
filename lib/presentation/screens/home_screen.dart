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
import 'package:aldeewan_mobile/presentation/widgets/tour_start_dialog.dart';
import 'package:aldeewan_mobile/presentation/providers/unread_count_provider.dart';
import 'package:aldeewan_mobile/presentation/providers/guided_tour_provider.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {  // REMOVED ShowcaseTourMixin
  bool _hasCheckedInitialBalance = false;
  bool _hasTourBeenChecked = false;  // NEW: Prevent multiple tour checks
  bool _isDialogShowing = false;  // NEW: Prevent multiple dialogs
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Only check tour ONCE per screen lifecycle to prevent loops
    if (!_hasTourBeenChecked) {
      _hasTourBeenChecked = true;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        // Check if guided tour is active and waiting for home screen
        final tourNotifier = ref.read(guidedTourProvider.notifier);
        if (tourNotifier.canStartTourForScreen(TourScreen.home)) {
          tourNotifier.markScreenTourStarted();
          _startHomeShowcase();
        }
      });
    }
  }
  
  void _startHomeShowcase() {
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        try {
          // ignore: deprecated_member_use
          ShowCaseWidget.of(context).startShowCase(ShowcaseKeys.homeKeys);
        } catch (e) {
          debugPrint('Home showcase error: $e');
        }
      }
    });
  }
  
  void _checkInitialBalancePrompt() async {
    if (_hasCheckedInitialBalance) return;
    _hasCheckedInitialBalance = true;
    
    final onboarding = ref.read(onboardingProvider);
    final guidedTour = ref.read(guidedTourProvider);
    
    // If guided tour is already active, don't show dialogs
    if (guidedTour.isActive) return;
    
    // FIRST APP START: Show initial balance dialog, then tour dialog
    if (!ref.read(onboardingServiceProvider).isInitialBalancePromptShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        
        // Wait for initial balance dialog to close
        await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const InitialBalanceDialog(),
        );
        
        // Show tour start dialog after initial balance
        if (mounted && !_isDialogShowing) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            _showTourStartDialog();
          }
        }
      });
      return;
    }
    
    // SUBSEQUENT APP STARTS: Show tour dialog if not completed
    if (!onboarding.tourCompleted && !_isDialogShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showTourStartDialog();
      });
    }
  }
  
  void _showTourStartDialog() {
    final onboarding = ref.read(onboardingProvider);
    final guidedTour = ref.read(guidedTourProvider);
    
    // Guards to prevent showing dialog when it shouldn't
    if (onboarding.tourCompleted) return;
    if (guidedTour.isActive) return;  // Tour already running
    if (guidedTour.dialogShown) return; // Dialog already shown/handled in this session
    if (_isDialogShowing) return;  // Dialog already showing
    
    _isDialogShowing = true;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => TourStartDialog(
        onStartTour: () {
          _isDialogShowing = false;
          // Start the cross-screen guided tour
          ref.read(guidedTourProvider.notifier).startTour(context);
        },
        onSkip: () {
          _isDialogShowing = false;
          // User skipped - mark tour completed
          ref.read(guidedTourProvider.notifier).skipTour();
        },
      ),
    );
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
                          child: Badge(
                            isLabelVisible: ref.watch(unreadNotificationCountProvider) > 0,
                            label: Text(ref.watch(unreadNotificationCountProvider).toString()),
                            child: Icon(LucideIcons.bell, color: theme.colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Hero Section (Net Position + Range Filter) - Tour Step 1
                  ShowcaseTarget(
                    showcaseKey: ShowcaseKeys.dashboardCards,
                    title: l10n.tour1Title,
                    description: l10n.tour1Desc,
                    child: const HeroSection(),
                  ),
                  SizedBox(height: 16.h),

                  // Budget & Goals Buttons - Tour Steps 3-4 wrapped
                  ShowcaseTarget(
                    showcaseKey: ShowcaseKeys.budgetCard,
                    title: l10n.tour3Title,
                    description: l10n.tour3Desc,
                    child: ShowcaseTarget(
                      showcaseKey: ShowcaseKeys.goalsCard,
                      title: l10n.tour4Title,
                      description: l10n.tour4Desc,
                      child: const DashboardButtons(),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Quick Actions - Tour Step 2
                  ShowcaseTarget(
                    showcaseKey: ShowcaseKeys.quickActions,
                    title: l10n.tour2Title,
                    description: l10n.tour2Desc,
                    child: const QuickActions(),
                  ),
                  SizedBox(height: 8.h),

                  // Tip Card for Quick Actions
                  const QuickActionsTip(),
                  SizedBox(height: 24.h),

                  // Summary Stats Grid - Debts Section
                  const SummaryGrid(section: SummarySection.debts),
                  SizedBox(height: 24.h),

                  // Summary Stats Grid - Monthly Section
                  const SummaryGrid(section: SummarySection.monthly),
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
