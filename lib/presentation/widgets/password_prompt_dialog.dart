import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PasswordPromptDialog extends StatefulWidget {
  final bool isCreateMode; // If true, shows confirm field
  
  const PasswordPromptDialog({
    super.key,
    this.isCreateMode = false,
  });

  static Future<String?> show(BuildContext context, {bool isCreateMode = false}) {
    return showDialog<String>(
      context: context,
      builder: (context) => PasswordPromptDialog(isCreateMode: isCreateMode),
    );
  }

  @override
  State<PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<PasswordPromptDialog> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        widget.isCreateMode ? l10n.backupEncrypt : l10n.enterPassword,
        textAlign: TextAlign.center,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.isCreateMode)
              Text(
                l10n.backupEncryptSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: 16.h),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                labelText: l10n.enterPassword, // Reuse key or "Password"
                prefixIcon: const Icon(LucideIcons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? LucideIcons.eye : LucideIcons.eyeOff),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.passwordRequired;
                }
                if (widget.isCreateMode && value.length < 4) {
                   return 'Make it stronger (4+ chars)'; // Todo localize if strict
                }
                return null;
              },
            ),
            if (widget.isCreateMode) ...[
              SizedBox(height: 12.h),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: "Confirm Password", // Need Localization Key? Using hardcoded fallback or recycle
                  prefixIcon: const Icon(LucideIcons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return "Passwords do not match"; // Need localization
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _passwordController.text);
            }
          },
          child: Text(widget.isCreateMode ? l10n.save : l10n.ok),
        ),
      ],
    );
  }
}
