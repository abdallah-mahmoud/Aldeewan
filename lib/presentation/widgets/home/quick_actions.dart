import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/data/services/receipt_scanner_service.dart';
import 'package:aldeewan_mobile/data/services/sound_service.dart';
import 'package:aldeewan_mobile/domain/utils/receipt_parser.dart';

class QuickActions extends ConsumerStatefulWidget {
  const QuickActions({super.key});

  @override
  ConsumerState<QuickActions> createState() => _QuickActionsState();
}

class _QuickActionsState extends ConsumerState<QuickActions> {
  bool _isScanning = false;

  Future<void> _scanReceipt(BuildContext context, WidgetRef ref) async {
    final scanner = ref.read(receiptScannerServiceProvider);
    final l10n = AppLocalizations.of(context)!;
    
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(LucideIcons.camera),
                title: Text(l10n.camera),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(LucideIcons.image),
                title: Text(l10n.gallery),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      // Pick image first (UI blocking)
      final image = await scanner.pickReceiptImage(source);
      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _isScanning = true;
      });

      // Add timeout to prevent infinite hanging
      final text = await scanner.extractTextFromImage(image).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception(l10n.scanTimeout),
      );
      
      final draft = ReceiptParser.parse(text);

      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        
        // Ask user where to save: Ledger (Debt) or Cashbook (Expense/Income)
        if (context.mounted) {
          final destination = await showModalBottomSheet<String>(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(LucideIcons.book),
                    title: Text(l10n.addToLedger),
                    subtitle: Text(l10n.addToLedgerSubtitle),
                    onTap: () => Navigator.pop(context, 'ledger'),
                  ),
                  ListTile(
                    leading: const Icon(LucideIcons.wallet),
                    title: Text(l10n.addToCashbook),
                    subtitle: Text(l10n.addToCashbookSubtitle),
                    onTap: () => Navigator.pop(context, 'cashbook'),
                  ),
                ],
              ),
            ),
          );

          if (destination == null) return;

          final path = destination == 'ledger' ? '/ledger' : '/cashbook';
          final action = destination == 'ledger' ? 'scan' : 'add'; // 'add' triggers modal in CashbookScreen

          final uri = Uri(path: path, queryParameters: {
            'action': action,
            if (draft.amount != null) 'amount': draft.amount.toString(),
            if (draft.date != null) 'date': draft.date!.toIso8601String(),
            if (draft.note != null) 'note': draft.note,
          });
          
          if (context.mounted) {
            context.push(uri.toString());
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.scanError(e.toString()))),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.quickActions,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, // Increased to fit more buttons
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0, // Square buttons
              children: [
                _buildActionButton(
                  context,
                  l10n.addDebt,
                  LucideIcons.filePlus2,
                  () => context.push('/ledger?action=debt'),
                  isDark,
                ),
                _buildActionButton(
                  context,
                  l10n.recordPayment,
                  LucideIcons.creditCard,
                  () => context.push('/ledger?action=payment'),
                  isDark,
                ),
                _buildActionButton(
                  context,
                  l10n.scanReceipt,
                  LucideIcons.scanLine,
                  () => _scanReceipt(context, ref),
                  isDark,
                ),
                _buildActionButton(
                  context,
                  l10n.addCashEntry,
                  LucideIcons.plusCircle,
                  () => context.push('/cashbook?action=add'),
                  isDark,
                ),
                _buildActionButton(
                  context,
                  l10n.viewBalances,
                  LucideIcons.scale,
                  () => context.go('/ledger'),
                  isDark,
                ),
              ],
            ),
          ],
        ),
        if (_isScanning)
          Positioned.fill(
            child: Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, VoidCallback onTap, bool isDark) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        ref.read(soundServiceProvider).playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8), // Added padding for overflow safety
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10), // Reduced padding for icon container
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 24), // Slightly smaller icon
            ),
            const SizedBox(height: 6), // Reduced spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11, // Slightly smaller base font
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
