import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    return RepaintBoundary(
      key: widget.repaintKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
            backgroundColor: Colors.white,
            data: widget.data,
            version: QrVersions.auto,
            size: MediaQuery.of(context).size.width * 0.6,
            errorStateBuilder: (cxt, err) => Center(
              child:
                  Text(AppLocalizations.of(context)!.qrcodeDisplay_pageTitle),
            ),
          ),
          Consumer<QRCodeDisplayViewModel>(
            builder: (_, vm, __) => vm.isLogoRemoved
                ? const SizedBox.shrink()
                : GestureDetector(
                    onTap: () => vm.promptRemoveLogo(context),
                    child: Image.asset('assets/img/logo.png',
                        width: 80, height: 80),
                  ),
          )
        ],
      ),
    );
  }
}
