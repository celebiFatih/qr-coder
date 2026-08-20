import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/l10n/app_localizations.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';
import 'package:qr_coder/viewmodels/qr_code_viewmodel.dart';

class _RecordingQrCodeRepository implements QRCodeRepository {
  _RecordingQrCodeRepository({this.insertCompleter});

  final Completer<void>? insertCompleter;
  final List<QRCodeModel> inserted = <QRCodeModel>[];

  @override
  Future<void> insertQrCode(QRCodeModel qrCode) async {
    inserted.add(qrCode);

    final completer = insertCompleter;
    if (completer != null) {
      await completer.future;
    }
  }

  @override
  Future<void> deleteAllQrCodes() async {}

  @override
  Future<void> deleteQrCode(String id) async {}

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async => <QRCodeModel>[];

  @override
  Future<void> updateQRCodeName(
    String id,
    Map<String, dynamic> updatedData,
  ) async {}
}

Future<BuildContext> _pumpLocalizedContext(WidgetTester tester) async {
  late BuildContext testContext;

  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          testContext = context;
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  await tester.pump();

  return testContext;
}

QRCodeViewModel _buildViewModel(_RecordingQrCodeRepository repository) {
  return QRCodeViewModel(
    isFirebaseUser: false,
    uid: null,
    repositoryFactory: (_, _) => repository,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rapid generate calls persist only one QR code', (tester) async {
    final insertCompleter = Completer<void>();
    final repository = _RecordingQrCodeRepository(
      insertCompleter: insertCompleter,
    );
    final viewModel = _buildViewModel(repository);
    addTearDown(viewModel.dispose);

    final context = await _pumpLocalizedContext(tester);
    viewModel.controller.text = 'double-submit-guard';

    final firstCall = viewModel.generateQRCode(context);

    expect(viewModel.isLoading, isTrue);
    expect(repository.inserted, hasLength(1));

    final secondCall = viewModel.generateQRCode(context);
    await tester.pump();

    expect(repository.inserted, hasLength(1));

    insertCompleter.complete();
    await Future.wait<void>(<Future<void>>[firstCall, secondCall]);

    expect(viewModel.isLoading, isFalse);
    expect(repository.inserted.single.data, 'double-submit-guard');
  });

  testWidgets('shared text longer than QR limit is never persisted', (
    tester,
  ) async {
    const channel = MethodChannel('com.qrcoder.app/app');
    final tooLongText = 'x' * (QRCodeViewModel.maxQrDataLength + 1);

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getSharedText');
          return tooLongText;
        });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final repository = _RecordingQrCodeRepository();
    final viewModel = _buildViewModel(repository);
    addTearDown(viewModel.dispose);

    final context = await _pumpLocalizedContext(tester);

    await viewModel.receiveSharedText(context);

    expect(repository.inserted, isEmpty);
    expect(viewModel.qrData, isEmpty);
    expect(viewModel.qrCodeModel, isNull);
    expect(viewModel.controller.text, tooLongText);
    expect(viewModel.errorMsg, 'Text is too long!');
  });

  testWidgets('shared text at the QR limit is preserved and persisted', (
    tester,
  ) async {
    const channel = MethodChannel('com.qrcoder.app/app');
    final acceptedText = 'x' * QRCodeViewModel.maxQrDataLength;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => acceptedText);

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    final repository = _RecordingQrCodeRepository();
    final viewModel = _buildViewModel(repository);
    addTearDown(viewModel.dispose);

    final context = await _pumpLocalizedContext(tester);

    await viewModel.receiveSharedText(context);

    expect(repository.inserted, hasLength(1));
    expect(repository.inserted.single.data, acceptedText);
    expect(viewModel.qrData, acceptedText);
    expect(viewModel.controller.text, acceptedText);
    expect(viewModel.errorMsg, isEmpty);
    expect(viewModel.isLoading, isFalse);
  });
}
