import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/viewmodels/qr_code_list_page_viewmodel.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';
import 'package:qr_flutter/qr_flutter.dart';

void main() {
  testWidgets('QR list preview receives the stored QR data', (tester) async {
    const expectedData = 'https://example.com/real-qr-data';
    final viewModel = QrCodeListPageViewmodel(isFirebaseUser: false, uid: null);
    viewModel.qrCodes = [
      QRCodeModel(
        id: '1',
        data: expectedData,
        name: 'Example',
        createdAt: '18.08.2026 10:30',
      ),
    ];

    const page = QRCodeListPage();

    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Builder(
            builder: (context) =>
                page.buildQRCodeListItem(context, viewModel, 0),
          ),
        ),
      ),
    );

    await tester.pump();

    final preview = tester.widget<QrCodePreviewImage>(
      find.byType(QrCodePreviewImage),
    );

    expect(preview.data, expectedData);
    expect(find.byType(QrImageView), findsOneWidget);
  });
}
