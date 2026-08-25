import 'package:flutter/material.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/widgets/app_components.dart';

class AppNavigationMenu extends StatelessWidget {
  const AppNavigationMenu({
    super.key,
    required this.isSignedIn,
    required this.sessionLabel,
    required this.onSavedQRCodes,
    required this.onSettings,
    required this.onLogout,
  });

  final bool isSignedIn;
  final String sessionLabel;
  final VoidCallback onSavedQRCodes;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: onSavedQRCodes,
          leadingIcon: const Icon(Icons.format_list_bulleted_rounded),
          child: Text(l10n.qrcodeGenerator_qrCodeListToolTip),
        ),
        MenuItemButton(
          onPressed: onSettings,
          leadingIcon: const Icon(Icons.settings_outlined),
          child: Text(l10n.settings_title),
        ),
        MenuItemButton(
          onPressed: onLogout,
          leadingIcon: const Icon(Icons.logout_rounded),
          child: Text(l10n.qrCodeGenerator_LogOutToolTip),
        ),
      ],
      builder: (context, controller, child) {
        return AppIconButton(
          tooltip: sessionLabel,
          semanticLabel: l10n.navigation_accountMenuSemantic(sessionLabel),
          onPressed: controller.isOpen ? controller.close : controller.open,
          icon: Icon(
            isSignedIn
                ? Icons.cloud_done_outlined
                : Icons.account_circle_outlined,
            color: isSignedIn ? Theme.of(context).colorScheme.tertiary : null,
          ),
        );
      },
    );
  }
}
