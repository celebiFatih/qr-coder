import 'package:flutter/material.dart';

Future<String?> showAccountDeletionPasswordDialog({
  required BuildContext context,
  required String title,
  required String description,
  required String passwordLabel,
  required String cancelLabel,
  required String deleteLabel,
}) {
  return showDialog<String>(
    context: context,
    builder: (_) => AccountDeletionPasswordDialog(
      title: title,
      description: description,
      passwordLabel: passwordLabel,
      cancelLabel: cancelLabel,
      deleteLabel: deleteLabel,
    ),
  );
}

class AccountDeletionPasswordDialog extends StatefulWidget {
  const AccountDeletionPasswordDialog({
    super.key,
    required this.title,
    required this.description,
    required this.passwordLabel,
    required this.cancelLabel,
    required this.deleteLabel,
  });

  final String title;
  final String description;
  final String passwordLabel;
  final String cancelLabel;
  final String deleteLabel;

  @override
  State<AccountDeletionPasswordDialog> createState() =>
      _AccountDeletionPasswordDialogState();
}

class _AccountDeletionPasswordDialogState
    extends State<AccountDeletionPasswordDialog> {
  late final TextEditingController _passwordController;

  bool _canDelete = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canDelete) {
      return;
    }

    Navigator.of(context).pop(_passwordController.text);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.description),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofocus: true,
              decoration: InputDecoration(
                labelText: widget.passwordLabel,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_rounded
                        : Icons.visibility_off_rounded,
                  ),
                ),
              ),
              onChanged: (value) {
                final canDelete = value.isNotEmpty;
                if (canDelete == _canDelete) {
                  return;
                }

                setState(() {
                  _canDelete = canDelete;
                });
              },
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: _canDelete ? _submit : null,
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
            foregroundColor: scheme.onError,
          ),
          child: Text(widget.deleteLabel),
        ),
      ],
    );
  }
}
