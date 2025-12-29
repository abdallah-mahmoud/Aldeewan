import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/utils/auth_service.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _showUnlockButton = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Play startup sound
    ref.read(soundServiceProvider).playStartup();
    
    // Start auth check after animation delay
    // Increased delay to allow users to read the Quran verse
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _checkAuth();
      }
    });
  }

  Future<void> _checkAuth() async {
    if (!mounted) return;
    
    // Check if app lock is enabled
    final isAppLockEnabled = ref.read(securityProvider);
    if (!isAppLockEnabled) {
      if (mounted) context.go('/home');
      return;
    }

    final isAvailable = await _authService.isBiometricAvailable();
    if (!mounted) return;

    if (isAvailable) {
      final l10n = AppLocalizations.of(context)!;
      final authenticated = await _authService.authenticate(l10n.authenticateReason);
      if (!mounted) return;
      
      if (authenticated) {
        context.go('/home');
      } else {
        setState(() {
          _showUnlockButton = true;
        });
      }
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 80,
                  height: 80,
                ),
              ).animate()
               .fade(duration: 600.ms)
               .scale(duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 24),
              
              // App Name
              Text(
                l10n.appName,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ).animate()
               .fade(delay: 300.ms, duration: 500.ms)
               .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 8),
              
              // Slogan
              Text(
                l10n.appSlogan,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ).animate()
               .fade(delay: 500.ms, duration: 500.ms),

              const SizedBox(height: 48),

              // Quran Verse
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا تَدَايَنْتُمْ بِدَيْنٍ إِلَىٰ أَجَلٍ مُسَمًّى فَاكْتُبُوهُ وَلْيَكْتُبْ بَيْنَكُمْ كَاتِبٌ بِالْعَدْلِ...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Amiri', // Amiri is elegant and appropriate for Quranic text
                        fontSize: 18.sp,
                        height: 2.0,
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '(البقرة: 282)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate()
               .fade(delay: 800.ms, duration: 800.ms)
               .slideY(begin: 0.1, end: 0),

              if (_showUnlockButton) ...[
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: _checkAuth,
                  icon: const Icon(LucideIcons.lock),
                  label: Text(l10n.unlock),
                ).animate().fade().scale(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
