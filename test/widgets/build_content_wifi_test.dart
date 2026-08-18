import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/widgets/build_content.dart';

void main() {
  Widget buildTestApp(String data) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        body: BuildContent(
          qrCode: QRCodeModel(
            id: 'wifi-test',
            data: data,
            name: 'Wi-Fi',
            createdAt: '18.08.2026 10:00',
          ),
        ),
      ),
    );
  }

  testWidgets('Wi-Fi QR without optional H field does not crash', (
    tester,
  ) async {
    const data = 'WIFI:T:WPA;S:OfficeWifi;P:secret123;;';

    await tester.pumpWidget(buildTestApp(data));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(data), findsOneWidget);
  });

  testWidgets('Wi-Fi QR with H field still renders normally', (tester) async {
    const data = 'WIFI:T:WPA;S:OfficeWifi;P:secret123;H:true;;';

    await tester.pumpWidget(buildTestApp(data));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text(data), findsOneWidget);
  });
}
