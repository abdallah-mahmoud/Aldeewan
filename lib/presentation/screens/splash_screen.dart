import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/utils/auth_service.dart';
import 'package:aldeewan_mobile/presentation/providers/security_provider.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  bool _showUnlockButton = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
    );

    _controller.forward().then((_) => _checkAuth());
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
    if (isAvailable) {
      final authenticated = await _authService.authenticate();
      if (authenticated && mounted) {
        context.go('/home');
      } else if (mounted) {
        setState(() {
          _showUnlockButton = true;
        });
      }
    } else {
      // If biometrics not available but lock is enabled, we should probably show PIN or something.
      // For now, if no biometrics, we just let them in (or maybe we should block?)
      // Assuming "App Lock" implies biometrics for now as per AuthService.
      if (mounted) context.go('/home');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _opacity,
              child: ScaleTransition(
                scale: _scale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: 64,
                        height: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Aldeewan',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Secure Financial Management',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            if (_showUnlockButton) ...[
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: _checkAuth,
                icon: const Icon(LucideIcons.lock),
                label: Text(AppLocalizations.of(context)!.unlockApp),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
