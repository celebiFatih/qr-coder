import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRCodeTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function() onPressed;
  const QRCodeTextField(
      {required this.controller,
      super.key,
      required this.focusNode,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: true,
      decoration: InputDecoration(
        hintText:
            AppLocalizations.of(context)!.qrCodeGenerator_textFieldHintText,
        hintStyle: TextStyle(
          color: const Color(0xFF757575).withOpacity(0.5),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF673AB7)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF673AB7)),
        ),
        suffixIcon: IconButton(
            icon: const Icon(
              Icons.clear,
              size: 28,
            ),
            onPressed: onPressed),
      ),
      style: const TextStyle(color: Color(0xFF212121)),
      minLines: 1, // Minimum number of lines
      maxLines: null, // No maximum limit on number of lines
      keyboardType: TextInputType.multiline,
    );
  }
}
