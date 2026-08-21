import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkable/linkable.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';

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
          style: Theme.of(context).textTheme.headlineLarge!
              .copyWith(fontSize: 26),
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

  String _valueForPrefix(
    List<String> parts,
    String prefix, {
    String defaultValue = '',
  }) {
    final normalizedPrefix = prefix.toUpperCase();

    for (final part in parts) {
      if (part.length >= prefix.length &&
          part.substring(0, prefix.length).toUpperCase() == normalizedPrefix) {
        return part.substring(prefix.length);
      }
    }

    return defaultValue;
  }

  Widget _buildWifi(BuildContext context, String wifiData) {
    final parts = wifiData.replaceFirst('WIFI:', '').split(';');
    final ssid = _valueForPrefix(parts, 'S:');
    final password = _valueForPrefix(parts, 'P:');
    final encryption = _valueForPrefix(parts, 'T:');
    final hidden = _valueForPrefix(parts, 'H:', defaultValue: 'false');

    return GestureDetector(
      onTap: () async {
        if (Theme.of(context).platform == TargetPlatform.android) {
          const intent = MethodChannel('com.qrcoder.app/app');
          try {
            await intent.invokeMethod('openWifiSettings');
          } on PlatformException catch (e) {
            debugPrint('Failed to open Wi-Fi settings: ${e.message}');
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
                  Text(
                    AppLocalizations.of(context)!
                        .qrCodeDetail_wifiPassw(password),
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .qrCodeDetail_wifiEncryption(encryption),
                  ),
                  Text(
                    AppLocalizations.of(context)!
                        .qrCodeDetail_wifiHidden(hidden),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!
                        .qrCodeDetail_wifiConnectTextBtn,
                  ),
                ),
              ],
            ),
          );
        }
      },
      child: Tooltip(
        message: AppLocalizations.of(context)!
            .qrCodeDetail_OpenWifiSettingsButton,
        child: Text(
          wifiData,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: Colors.blue),
        ),
      ),
    );
  }
}
