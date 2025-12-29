import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutApp),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
        child: Column(
          children: [
            // App Logo
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: Image.asset(
                  'assets/images/logo.png', // Ensure this exists or use an icon fallback
                  errorBuilder: (context, error, stackTrace) => Icon(
                    LucideIcons.wallet,
                    size: 50.sp,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Aldeewan',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              l10n.appVersionInfo('2.2.0'),
              style: theme.textTheme.bodySmall,
            ),
            SizedBox(height: 32.h),
            
            // Description
            Text(
              l10n.aboutAldeewanDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
            ),
            
            SizedBox(height: 40.h),
            
            // Features / Info Tiles
            _buildInfoCard(
              context,
              children: [
                _buildInfoTile(
                  context,
                  icon: LucideIcons.checkCircle2,
                  title: l10n.appFeatures,
                  onTap: () {
                    // Could show a dialog with features
                    _showFeaturesDialog(context, l10n);
                  },
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: LucideIcons.fileText,
                  title: l10n.termsOfService,
                  subtitle: l10n.comingSoon,
                  onTap: () {},  // No action until document is ready
                  enabled: false,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: LucideIcons.shieldCheck,
                  title: l10n.privacyPolicy,
                  onTap: () => _launchUrl('https://docs.google.com/document/d/1mzfbH2PyfqQEV6EXh5fPje8mvmaATbNt57_tYfMwTsE/edit?usp=sharing'),
                ),
              ],
            ),
            
            SizedBox(height: 48.h),
            
            // Footer
            Text(
              l10n.madeWithLove,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            SizedBox(height: 8.h),
            Text(
              '© 2025 Motaasl for Software Solutions',
              style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return ListTile(
      onTap: enabled ? onTap : null,
      leading: Icon(icon, size: 20.sp, color: enabled ? Theme.of(context).colorScheme.primary : Colors.grey),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: enabled ? null : Colors.grey,
      )),
      subtitle: subtitle != null ? Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)) : null,
      trailing: enabled ? const Icon(Icons.chevron_right) : null,
    );
  }

  void _showFeaturesDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.appFeatures),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FeatureItem(icon: LucideIcons.wallet, text: l10n.featureManageCash),
            _FeatureItem(icon: LucideIcons.users, text: l10n.featureTrackDebts),
            _FeatureItem(icon: LucideIcons.pieChart, text: l10n.featureAnalytics),
            _FeatureItem(icon: LucideIcons.cloud, text: l10n.featureBackup),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.ok)),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
