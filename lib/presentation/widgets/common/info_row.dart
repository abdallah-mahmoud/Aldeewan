import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? customValue;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.customValue,
  }) : assert(value != null || customValue != null, 'Either value or customValue must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (value != null)
                Text(
                  value!,
                  style: theme.textTheme.bodyLarge,
                )
              else
                customValue!,
            ],
          ),
        ),
      ],
    );
  }
}
