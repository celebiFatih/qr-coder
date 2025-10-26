import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math' as math;

class QRcodeDisplay extends StatefulWidget {
  const QRcodeDisplay(
      {super.key, required this.data, required this.repaintKey});
  final String data;
  final GlobalKey repaintKey;

  @override
  State<QRcodeDisplay> createState() => _QRcodeDisplayState();
}

class _QRcodeDisplayState extends State<QRcodeDisplay> {
  @override
  void initState() {
    super.initState();
    // Logo varsayılan olarak görünsün; sadece sayfa açılırken 1 kez sıfırla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QRCodeDisplayViewModel>().resetLogo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side =
            math.min(constraints.maxWidth, constraints.maxHeight) * 0.85;
        final logoRatio = 0.12;
        final logoSide = side * logoRatio;

        return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RepaintBoundary(
                key: widget.repaintKey,
                child: SizedBox.square(
                  dimension: side,
                  child: Consumer<QRCodeDisplayViewModel>(
                    builder: (context, vm, child) => Stack(children: [
                      QrImageView(
                        data: widget.data,
                        backgroundColor: Colors.white,
                        version: QrVersions.auto,
                        errorCorrectionLevel: QrErrorCorrectLevel.H,
                        embeddedImage: vm.isLogoRemoved
                            ? null
                            : const AssetImage('assets/img/logo.png'),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                            size: Size(logoSide, logoSide)),
                        errorStateBuilder: (cxt, err) => Center(
                          child: Text(AppLocalizations.of(context)!
                              .qrcodeDisplay_pageTitle),
                        ),
                      ),
                      if (!vm.isLogoRemoved)
                        Center(
                          child: SizedBox(
                            width: logoSide,
                            height: logoSide,
                            child: GestureDetector(
                              onTap: () => vm.promptRemoveLogo(context),
                              // Görünmez; sadece hit-test için
                              behavior: HitTestBehavior.opaque,
                            ),
                          ),
                        )
                    ]),
                  ),
                ),
              ),
            ]);
      },
    );
  }
}
