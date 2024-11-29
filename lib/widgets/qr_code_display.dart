import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_coder/viewmodels/qr_code_display_viewmodel.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRcodeDisplay extends StatelessWidget {
  final String data;
  final GlobalKey repaintKey;
  const QRcodeDisplay(
      {required this.data, required this.repaintKey, super.key});

  @override
  Widget build(BuildContext context) {
    final qrCodeDisplayViewModel =
        Provider.of<QRCodeDisplayViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      qrCodeDisplayViewModel.resetLogo();
    });
    return RepaintBoundary(
      key: repaintKey,
      child: Stack(
        alignment: Alignment.center,
        children: [
          QrImageView(
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
          // if (!qrCodeDisplayViewModel.isLogoRemoved)
          Consumer<QRCodeDisplayViewModel>(
            builder: (context, viewModel, child) {
              return Positioned(
                child: GestureDetector(
                  onTap: () => viewModel.promptRemoveLogo(context),
                  child: !viewModel.isLogoRemoved
                      ? Image.asset('assets/img/logo.png',
                          width: 80, height: 80)
                      : const SizedBox.shrink(),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
