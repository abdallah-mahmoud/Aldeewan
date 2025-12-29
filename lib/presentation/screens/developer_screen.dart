import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Handle error gracefully, maybe show a snackbar
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutDeveloper),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Profile Picture
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.surface,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/PFP.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Name
            Text(
              l10n.developerName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
            ),
            const SizedBox(height: 8),
            // Tagline
            Text(
              l10n.developerTagline,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            // Links Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                children: [
                  _buildLinkItem(
                    context,
                    icon: LucideIcons.facebook,
                    label: l10n.facebook,
                    subLabel: '@motaasl8',
                    color: const Color(0xFF1877F2),
                    onTap: () => _launchUrl('https://www.facebook.com/motaasl8'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildLinkItem(
                    context,
                    icon: LucideIcons.instagram,
                    label: l10n.instagram,
                    subLabel: '@motaasl8',
                    color: const Color(0xFFE4405F),
                    onTap: () => _launchUrl('https://www.instagram.com/motaasl8'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildLinkItem(
                    context,
                    icon: LucideIcons.mail,
                    label: l10n.email,
                    subLabel: 'abdo13-m.azme@hotmail.com',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onTap: () => _launchUrl('mailto:abdo13-m.azme@hotmail.com'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildLinkItem(
                    context,
                    icon: LucideIcons.phone,
                    label: l10n.phone,
                    subLabel: '+249 111 950 191',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onTap: () => _launchUrl('tel:+249111950191'),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildLinkItem(
                    context,
                    icon: LucideIcons.github,
                    label: l10n.openSourceLink,
                    subLabel: '',
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    onTap: () => _launchUrl('https://github.com/abdallah-mahmoud/Aldeewan'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Footer
            Text(
              l10n.islamicEndowment,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: subLabel.isNotEmpty
          ? Text(
              subLabel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}
