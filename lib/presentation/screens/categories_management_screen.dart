import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aldeewan_mobile/presentation/providers/category_provider.dart';
import 'package:aldeewan_mobile/presentation/models/category.dart';
import 'package:aldeewan_mobile/utils/category_helper.dart';
import 'package:aldeewan_mobile/utils/icon_helper.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';

class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageCategories),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
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
            onTap: () {
              // Maybe show details or edit in future
              if (category.isCustom) {
                 // For now, just show delete confirmation on tap for custom ones, 
                 // or maybe we want to edit.
                 // Let's stick to long press for delete as per standard, 
                 // or maybe tap to edit/delete.
                 _confirmDelete(context, ref, category);
              }
            },
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
                            border: Border.all(color: theme.dividerColor),
                          ),
                          child: const Icon(LucideIcons.trash2, size: 12, color: Colors.red),
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
    );
  }

  Widget _buildAddButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
              Icons.add,
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.create,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Category category) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategoryTitle),
        content: Text(l10n.deleteCategoryContent(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              try {
                ref.read(categoryProvider.notifier).deleteCategory(category.id.toString());
                Navigator.pop(context);
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    Color selectedColor = Colors.blue;
    String selectedIcon = 'tag';
    String selectedType = 'expense';

    showDialog(
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
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(l10n.categoryType),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: selectedType,
                      items: [
                        DropdownMenuItem(value: 'expense', child: Text(l10n.expense)),
                        DropdownMenuItem(value: 'income', child: Text(l10n.income)),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => selectedType = val);
                      },
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
                    Colors.purple, Colors.teal, Colors.pink, Colors.indigo
                  ].map((color) => InkWell(
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
                  )).toList(),
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
                      final iconData = IconHelper.getIcon(iconName);
                      return InkWell(
                        onTap: () => setState(() => selectedIcon = iconName),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedIcon == iconName ? Theme.of(context).colorScheme.primaryContainer : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData, size: 20),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
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
