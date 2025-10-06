import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_coder/l10n/app_localizations.dart';

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = AppLocalizations.of(context)!
            .scannerErrorWidget_controllerUninitialized;
      case MobileScannerErrorCode.permissionDenied:
        errorMessage =
            AppLocalizations.of(context)!.scannerErrorWidget_permissionDenied;
      case MobileScannerErrorCode.unsupported:
        errorMessage =
            AppLocalizations.of(context)!.scannerErrorWidget_unsupported;
      default:
        errorMessage = AppLocalizations.of(context)!.scannerErrorWidget_unknown;
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
