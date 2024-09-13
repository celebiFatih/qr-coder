import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRcodeDisplay extends StatelessWidget {
  final String data;
  final GlobalKey repaintKey;
  const QRcodeDisplay(
      {required this.data, required this.repaintKey, super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: repaintKey,
      child: QrImageView(
        backgroundColor: Colors.white,
        data: data,
        version: QrVersions.auto,
        size: MediaQuery.of(context).size.width * 0.6,
        errorStateBuilder: (cxt, err) {
          return Center(
            child: Text(
              AppLocalizations.of(context)!.qrcodeDisplay_pageTitle,
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }
}
