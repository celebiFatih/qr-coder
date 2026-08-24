import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/widgets/app_components.dart';

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error, this.onRetry});

  final MobileScannerException error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final errorMessage = switch (error.errorCode) {
      MobileScannerErrorCode.controllerUninitialized =>
        l10n.scannerErrorWidget_controllerUninitialized,
      MobileScannerErrorCode.permissionDenied =>
        l10n.scannerErrorWidget_permissionDenied,
      MobileScannerErrorCode.unsupported => l10n.scannerErrorWidget_unsupported,
      _ => l10n.scannerErrorWidget_unknown,
    };

    return ColoredBox(
      color: scheme.surface,
      child: AppStateView.error(
        message: errorMessage,
        action: onRetry == null
            ? null
            : FilledButton.tonalIcon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.scannerPage_refreshBtnToolTip),
              ),
      ),
    );
  }
}
