import 'package:flutter/material.dart';
import 'package:aldeewan_mobile/domain/entities/person.dart';
import 'package:uuid/uuid.dart';
import 'package:aldeewan_mobile/l10n/generated/app_localizations.dart';
import 'package:aldeewan_mobile/utils/toast_service.dart';

class PersonForm extends StatefulWidget {
  final Person? person;
  final Function(Person) onSave;

  const PersonForm({super.key, this.person, required this.onSave});

  @override
  State<PersonForm> createState() => _PersonFormState();
}

class _PersonFormState extends State<PersonForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late PersonRole _role;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.person?.name ?? '');
    _phoneController = TextEditingController(text: widget.person?.phone ?? '');
    _role = widget.person?.role ?? PersonRole.customer;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save(AppLocalizations l10n) {
    if (_formKey.currentState!.validate()) {
      final person = Person(
        id: widget.person?.id ?? const Uuid().v4(),
        role: _role,
        name: _nameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        createdAt: widget.person?.createdAt ?? DateTime.now(),
      );
      widget.onSave(person);
      ToastService.showSuccess(context, l10n.savedSuccessfully);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.person == null ? l10n.addPerson : l10n.edit, // 'Edit' might be too short, maybe 'Edit Person' key needed
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterName;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PersonRole>(
              value: _role,
              decoration: InputDecoration(
                labelText: l10n.role,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(
                  value: PersonRole.customer,
                  child: Text(l10n.customer),
                ),
                DropdownMenuItem(
                  value: PersonRole.supplier,
                  child: Text(l10n.supplier),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _role = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => _save(l10n),
              child: Text(l10n.save),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
