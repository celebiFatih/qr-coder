import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkable/linkable.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BuildContent extends StatelessWidget {
  final QRCodeModel qrCode;
  const BuildContent({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.qrCodeDetail_Details,
          style:
              Theme.of(context).textTheme.headlineLarge!.copyWith(fontSize: 26),
        ),
        const Divider(height: 2.0),
        Expanded(
          child: SingleChildScrollView(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              elevation: 4.0,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildContent(context, qrCode.data),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, String data) {
    if (_isWifi(data)) {
      return _buildWifi(context, data);
    }
    return Linkable(text: data, style: Theme.of(context).textTheme.bodyLarge);
  }

  bool _isWifi(String data) {
    final wifiRegExp = RegExp(
      r'^WIFI:T:(WPA|WEP|nopass);S:[^;]+;P:[^;]*;(H:(true|false);)?;$',
      caseSensitive: false,
    );
    return wifiRegExp.hasMatch(data);
  }

  Widget _buildWifi(BuildContext context, String wifiData) {
    final parts = wifiData.replaceFirst('WIFI:', '').split(';');
    final ssid = parts.firstWhere((part) => part.startsWith('S:')).substring(2);
    final password =
        parts.firstWhere((part) => part.startsWith('P:')).substring(2);
    final encryption =
        parts.firstWhere((part) => part.startsWith('T:')).substring(2);
    final hidden =
        parts.firstWhere((part) => part.startsWith('H:')).substring(2);

    return GestureDetector(
      onTap: () async {
        if (Theme.of(context).platform == TargetPlatform.android) {
          const intent = MethodChannel('com.qrcoder.app/app');
          try {
            await intent.invokeMethod('openWifiSettings');
          } on PlatformException catch (e) {
            print("Failed to open Wi-Fi settings: ${e.message}");
          }
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(AppLocalizations.of(context)!.qrCodeDetail_wifiInfo),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('SSID: $ssid'),
                  Text(AppLocalizations.of(context)!
                      .qrCodeDetail_wifiPassw(password)),
                  Text(AppLocalizations.of(context)!
                      .qrCodeDetail_wifiEncryption(encryption)),
                  Text(AppLocalizations.of(context)!
                      .qrCodeDetail_wifiHidden(hidden)),
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!
                        .qrCodeDetail_wifiConnectTextBtn))
              ],
            ),
          );
        }
      },
      child: Tooltip(
        message:
            AppLocalizations.of(context)!.qrCodeDetail_OpenWifiSettingsButton,
        child: Text(
          wifiData,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Colors.blue),
        ),
      ),
    );
  }
}
