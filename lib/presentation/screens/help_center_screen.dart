import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/presentation/providers/onboarding_provider.dart';
import 'package:aldeewan_mobile/config/app_colors.dart';

class HelpCenterScreen extends ConsumerWidget {
  const HelpCenterScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpCenter),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Getting Started Section
          _buildSectionHeader(context, l10n.faqGettingStarted, LucideIcons.bookOpen),
          const SizedBox(height: 8),
          _buildFaqCard(
            context,
            isDark: isDark,
            children: [
              _buildFaqItem(
                context,
                question: l10n.faqWhatIsAldeewan,
                answer: l10n.faqWhatIsAldeewaAnswer,
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: l10n.faqHowToAddTransaction,
                answer: l10n.faqHowToAddTransactionAnswer,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Data & Backup Section
          _buildSectionHeader(context, l10n.faqDataBackup, LucideIcons.database),
          const SizedBox(height: 8),
          _buildFaqCard(
            context,
            isDark: isDark,
            children: [
              _buildFaqItem(
                context,
                question: l10n.faqHowToBackup,
                answer: l10n.faqHowToBackupAnswer,
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: l10n.faqHowToRestore,
                answer: l10n.faqHowToRestoreAnswer,
              ),
              const Divider(height: 1),
              _buildFaqItem(
                context,
                question: l10n.faqWhereIsData,
                answer: l10n.faqWhereIsDataAnswer,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Contact Support Section
          _buildSectionHeader(context, l10n.contactSupport, LucideIcons.messageCircle),
          const SizedBox(height: 8),
          _buildContactCard(
            context,
            isDark: isDark,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.mail, color: AppColors.primary),
                title: Text(l10n.email),
                subtitle: Text(l10n.developerEmail),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () => _launchUrl('mailto:${l10n.developerEmail}'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: const Icon(LucideIcons.phone, color: AppColors.success),
                title: Text(l10n.phone),
                subtitle: const Text('+249 111 950 191'),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () => _launchUrl('tel:+249111950191'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(LucideIcons.facebook, color: Colors.blue[700]),
                title: Text(l10n.facebook),
                subtitle: const Text('@motaasl8'),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () => _launchUrl('https://www.facebook.com/motaasl8'),
              ),
              const Divider(height: 1, indent: 56),
              ListTile(
                leading: Icon(LucideIcons.instagram, color: Colors.pink[400]),
                title: Text(l10n.instagram),
                subtitle: const Text('@motaasl8'),
                trailing: const Icon(LucideIcons.chevronRight, size: 18),
                onTap: () => _launchUrl('https://www.instagram.com/motaasl8'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Restart Tour Button
          _buildSectionHeader(context, l10n.restartTour, LucideIcons.refreshCcw),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: ListTile(
              leading: const Icon(LucideIcons.play, color: AppColors.primary),
              title: Text(l10n.restartTour),
              subtitle: Text(l10n.restartTourSubtitle),
              trailing: const Icon(LucideIcons.chevronRight, size: 18),
              onTap: () {
                ref.read(onboardingProvider.notifier).resetAll();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.restartTourSubtitle),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFaqCard(BuildContext context, {required bool isDark, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildContactCard(BuildContext context, {required bool isDark, required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFaqItem(BuildContext context, {required String question, required String answer}) {
    final theme = Theme.of(context);
    return ExpansionTile(
      title: Text(
        question,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(
          answer,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
