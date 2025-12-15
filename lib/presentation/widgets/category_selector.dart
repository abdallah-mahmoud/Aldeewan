import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/category_provider.dart';
import 'package:aldeewan_mobile/presentation/models/category.dart';
import 'package:aldeewan_mobile/utils/icon_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

import 'package:aldeewan_mobile/utils/category_helper.dart';

class CategorySelector extends ConsumerWidget {
  final Function(Category) onSelected;
  final String? filterType; // 'income' or 'expense'

  const CategorySelector({
    super.key, 
    required this.onSelected,
    this.filterType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCategories = ref.watch(categoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Filter categories if filterType is provided
    final categories = filterType != null
        ? allCategories.where((c) => c.type == filterType).toList()
        : allCategories;

    return Container(
      height: 500,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.category, // Use localized title
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == categories.length) {
                  return _buildAddButton(context, ref);
                }
                final category = categories[index];
                return InkWell(
                  onTap: () => onSelected(category),
                  onLongPress: category.isCustom ? () => _confirmDelete(context, ref, category) : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: category.color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 24,
                            ),
                          ),
                          if (category.isCustom)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 10, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        CategoryHelper.getLocalizedCategory(category.name, l10n),
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => _showAddCategoryDialog(context, ref),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.plus,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add New',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryContent(category.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        ref.read(categoryProvider.notifier).deleteCategory(category.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showAddCategoryDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    String selectedIcon = 'helpCircle';
    Color selectedColor = Colors.blue;
    String selectedType = 'expense';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.newCategoryTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: l10n.category),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.categoryType),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.expense),
                      selected: selectedType == 'expense',
                      onSelected: (b) => setState(() => selectedType = 'expense'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.income),
                      selected: selectedType == 'income',
                      onSelected: (b) => setState(() => selectedType = 'income'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(l10n.selectColor),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Colors.blue, Colors.red, Colors.green, Colors.orange, 
                    Colors.purple, Colors.teal, Colors.pink, Colors.amber,
                    Colors.indigo, Colors.brown, Colors.grey, Colors.cyan
                  ].map((color) {
                    return InkWell(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor == color ? Border.all(width: 2, color: Colors.black) : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(l10n.selectIcon),
                const SizedBox(height: 8),
                SizedBox(
                  height: 150,
                  width: double.maxFinite,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: IconHelper.allIconNames.length,
                    itemBuilder: (context, index) {
                      final iconName = IconHelper.allIconNames[index];
                      return InkWell(
                        onTap: () => setState(() => selectedIcon = iconName),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedIcon == iconName ? Colors.grey.withValues(alpha: 0.2) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            IconHelper.getIcon(iconName),
                            color: selectedIcon == iconName ? selectedColor : Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
            FilledButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  ref.read(categoryProvider.notifier).addCategory(
                    nameController.text,
                    selectedIcon,
                    selectedColor,
                    selectedType,
                  );
                  Navigator.pop(context);
                }
              },
              child: Text(l10n.create),
            ),
          ],
        ),
      ),
    );
  }
}
