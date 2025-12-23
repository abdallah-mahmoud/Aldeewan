import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aldeewan_mobile/data/models/currency_data.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// A bottom sheet widget for selecting a currency with search functionality
class CurrencySelectorSheet extends StatefulWidget {
  final String currentCurrency;
  final ValueChanged<String> onSelected;

  const CurrencySelectorSheet({
    super.key,
    required this.currentCurrency,
    required this.onSelected,
  });

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();

  /// Shows the currency selector as a modal bottom sheet
  static Future<String?> show(BuildContext context, String currentCurrency) async {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => CurrencySelectorSheet(
          currentCurrency: currentCurrency,
          onSelected: (code) => Navigator.pop(context, code),
        ),
      ),
    );
  }
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CurrencyInfo> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return supportedCurrencies;
    }
    
    final query = _searchQuery.toLowerCase();
    return supportedCurrencies.where((currency) {
      return currency.code.toLowerCase().contains(query) ||
          currency.nameEn.toLowerCase().contains(query) ||
          currency.nameAr.contains(query) ||
          currency.symbol.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Column(
      children: [
        // Handle bar
        Container(
          margin: EdgeInsets.only(top: 12.h),
          width: 40.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        // Title
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Text(
            l10n.selectCurrency,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Search bar
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.search,
              prefixIcon: const Icon(LucideIcons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        SizedBox(height: 8.h),
        // Currency list
        Expanded(
          child: _filteredCurrencies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.searchX,
                        size: 48.sp,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        l10n.noResults,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredCurrencies.length,
                  itemBuilder: (context, index) {
                    final currency = _filteredCurrencies[index];
                    final isSelected = currency.code == widget.currentCurrency;

                    return ListTile(
                      leading: Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          currency.symbol,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? theme.colorScheme.onPrimaryContainer
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      title: Text(
                        isArabic ? currency.nameAr : currency.nameEn,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                      ),
                      subtitle: Text(
                        currency.code,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              LucideIcons.check,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                      onTap: () => widget.onSelected(currency.code),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
