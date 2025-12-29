import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  // Track expanded state for sections if needed, or rely on ExpansionTile automatic behavior
  
  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpCenter),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.lifeBuoy, size: 32, color: theme.colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.helpCenterSubtitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.tourHelp,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 1. Dashboard & Basics
          _buildCategorySection(
            context,
            title: l10n.faqDashboard,
            icon: LucideIcons.layoutDashboard,
            children: [
              _buildFaqItem(context, l10n.faqWhatIsAldeewan, l10n.faqWhatIsAldeewaAnswer),
              _buildFaqItem(context, l10n.faqWhatIsNetPosition, l10n.faqWhatIsNetPositionAnswer),
              _buildFaqItem(context, l10n.faqWhatIsTrueIncome, l10n.faqWhatIsTrueIncomeAnswer),
            ],
          ),

          // 2. Ledger (People)
          _buildCategorySection(
            context,
            title: l10n.faqLedger,
            icon: LucideIcons.users,
            children: [
              _buildFaqItem(context, l10n.faqHowToTrackDebt, l10n.faqHowToTrackDebtAnswer),
              _buildFaqItem(context, l10n.faqWhatIsOldDebt, l10n.faqWhatIsOldDebtAnswer),
            ],
          ),

          // 3. Cashbook
          _buildCategorySection(
            context,
            title: l10n.faqCashbook,
            icon: LucideIcons.wallet,
            children: [
              _buildFaqItem(context, l10n.faqCashbookVsLedger, l10n.faqCashbookVsLedgerAnswer),
              _buildFaqItem(context, l10n.faqHowToAddTransaction, l10n.faqHowToAddTransactionAnswer),
            ],
          ),

          // 4. Budgets & Goals
          _buildCategorySection(
            context,
            title: l10n.faqBudgetsGoals,
            icon: LucideIcons.target,
            children: [
              _buildFaqItem(context, l10n.faqHowToBudget, l10n.faqHowToBudgetAnswer),
            ],
          ),

          // 5. Reports
          _buildCategorySection(
            context,
            title: l10n.faqReports,
            icon: LucideIcons.barChart2,
            children: [
              _buildFaqItem(context, l10n.faqHowToExport, l10n.faqHowToExportAnswer),
            ],
          ),

          // 6. Data & Backup
          _buildCategorySection(
            context,
            title: l10n.faqDataBackup,
            icon: LucideIcons.database,
            children: [
              _buildFaqItem(context, l10n.faqWhereIsData, l10n.faqWhereIsDataAnswer),
              _buildFaqItem(context, l10n.faqHowToBackup, l10n.faqHowToBackupAnswer),
              _buildFaqItem(context, l10n.faqHowToRestore, l10n.faqHowToRestoreAnswer),
            ],
          ),

          const SizedBox(height: 24),
          
          // Contact & Actions
          Text(
            l10n.contactSupport,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          
           _buildActionCard(
            context,
            title: l10n.restartTour,
            subtitle: l10n.restartTourSubtitle,
            icon: LucideIcons.refreshCcw,
            color: Colors.orange,
            onTap: () {
              ref.read(onboardingProvider.notifier).resetAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.restartTourSubtitle)),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: l10n.email,
            subtitle: l10n.developerEmail,
            icon: LucideIcons.mail,
            color: AppColors.primary,
            onTap: () => _launchUrl('mailto:${l10n.developerEmail}'),
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            title: l10n.facebook,
            subtitle: '@motaasl8',
            icon: LucideIcons.facebook,
            color: Colors.blue[800]!,
            onTap: () => _launchUrl('https://www.facebook.com/motaasl8'),
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ExpansionTile(
          shape: Border.all(color: Colors.transparent),
          collapsedShape: Border.all(color: Colors.transparent),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          children: children,
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        dense: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        collapsedShape: const Border(),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 6, right: 8), // Localized margin? RTL safe if Directionality used
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  answer,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: theme.textTheme.bodySmall),
        trailing: const Icon(LucideIcons.chevronRight, size: 16),
        onTap: onTap,
      ),
    );
  }
}
