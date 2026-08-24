import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/widgets/app_components.dart';

class QRCodeTextField extends StatelessWidget {
  const QRCodeTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onPressed,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: false,
      minLines: 3,
      maxLines: 8,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        hintText: l10n.qrCodeGenerator_textFieldHintText,
        prefixIcon: const Icon(Icons.notes_rounded),
        suffixIcon: AppIconButton(
          tooltip: l10n.qrCodeGenerator_clearTextToolTip,
          onPressed: onPressed,
          icon: const Icon(Icons.clear_rounded),
        ),
      ),
    );
  }
}
