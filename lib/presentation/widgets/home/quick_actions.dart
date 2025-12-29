import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            SizedBox(height: 12.h),
            LayoutBuilder(
              builder: (context, constraints) {
                // Calculate responsive height based on screen width
                final screenWidth = MediaQuery.of(context).size.width;
                final chipHeight = (screenWidth * 0.22).clamp(75.0, 95.0);
                
                return SizedBox(
                  height: chipHeight,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.02, 0.98, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          _buildActionChip(
                            context,
                            l10n.addDebt,
                            LucideIcons.filePlus2,
                            () => context.push('/ledger?action=debt'),
                            isDark,
                          ),
                          SizedBox(width: 10.w),
                          _buildActionChip(
                            context,
                            l10n.recordPayment,
                            LucideIcons.creditCard,
                            () => context.push('/ledger?action=payment'),
                            isDark,
                          ),
                          SizedBox(width: 10.w),
                          _buildActionChip(
                            context,
                            l10n.scanReceipt,
                            LucideIcons.scanLine,
                            () => _scanReceipt(context, ref),
                            isDark,
                          ),
                          SizedBox(width: 10.w),
                          _buildActionChip(
                            context,
                            l10n.addCashEntry,
                            LucideIcons.plusCircle,
                            () => context.push('/cashbook?action=add'),
                            isDark,
                          ),
                          SizedBox(width: 10.w),
                          _buildActionChip(
                            context,
                            l10n.viewBalances,
                            LucideIcons.scale,
                            () => context.go('/analytics?tab=debts'),
                            isDark,
                          ),
                          SizedBox(width: 4.w),
                        ],
                      ),
                    ),
                  ),
                );
              },
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

  Widget _buildActionChip(
      BuildContext context, String label, IconData icon, VoidCallback onTap, bool isDark) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive sizing: scales with screen but has min/max bounds
    final chipWidth = (screenWidth * 0.26).clamp(85.0, 110.0);
    final iconSize = (screenWidth * 0.055).clamp(18.0, 24.0);
    final iconPadding = (screenWidth * 0.02).clamp(6.0, 10.0);
    
    return InkWell(
      onTap: () {
        ref.read(soundServiceProvider).playClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: chipWidth,
        constraints: BoxConstraints(
          minHeight: 70,
          maxHeight: 90,
        ),
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: iconSize),
            ),
            SizedBox(height: 4.h),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
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
