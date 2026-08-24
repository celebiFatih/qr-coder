import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String listPage;
  late String detailPage;
  late String buildContent;

  setUpAll(() {
    listPage = File('lib/views/qr_code_list_page.dart').readAsStringSync();
    detailPage = File('lib/views/qr_code_detail_page.dart').readAsStringSync();
    buildContent = File('lib/widgets/build_content.dart').readAsStringSync();
  });

  test('QR list separates normal and contextual selection actions', () {
    expect(listPage, contains('selectionMode: _selectionMode'));
    expect(listPage, contains('qrCodeList_selectedCount'));
    expect(listPage, contains('PopupMenuButton<_QrCodeListItemAction>'));
    expect(listPage, contains('Checkbox('));
    expect(listPage, contains('_enterSelectionModeWith'));
    expect(listPage, isNot(contains('FloatingActionButton(')));
    expect(listPage, isNot(contains('Color(0xFFCDDC39)')));
  });

  test('destructive list actions require explicit confirmation', () {
    expect(listPage, contains('_confirmDelete('));
    expect(listPage, contains('qrCodeList_deleteConfirmTitle'));
    expect(listPage, contains('qrCodeList_deleteSelectedConfirmTitle'));
    expect(listPage, contains('qrCodeList_deleteAllConfirmTitle'));
    expect(listPage, contains('backgroundColor: scheme.error'));
    expect(listPage, contains('foregroundColor: scheme.onError'));
  });

  test('list CRUD still delegates to the existing viewmodel operations', () {
    expect(listPage, contains('viewModel.updateQRCodeName('));
    expect(listPage, contains('viewModel.deleteQRCode('));
    expect(listPage, contains('viewModel.deleteSelectedQRCodes('));
    expect(listPage, contains('viewModel.deleteAllQRCodes('));
  });

  test('detail places save and share inside the content hierarchy', () {
    expect(detailPage, contains('AppContentFrame('));
    expect(detailPage, contains('AppSurface('));
    expect(detailPage, contains('FilledButton.icon('));
    expect(detailPage, contains('OutlinedButton.icon('));
    expect(detailPage, contains('SnackBarAction('));
    expect(detailPage, isNot(contains('FloatingActionButton(')));
    expect(detailPage, isNot(contains('elevation: 8')));
  });

  test('detail resolution picker is a safe Material 3 modal sheet', () {
    expect(detailPage, contains('showModalBottomSheet<double>('));
    expect(detailPage, contains('useSafeArea: true'));
    expect(detailPage, contains('showDragHandle: true'));
    expect(detailPage, contains('isScrollControlled: true'));
    expect(
      detailPage,
      isNot(
        contains('backgroundColor: Theme.of(context).colorScheme.secondary'),
      ),
    );
  });

  test('detail save/share keep the existing viewmodel entry points', () {
    expect(detailPage, contains('viewModel.saveQrCode('));
    expect(detailPage, contains('viewModel.shareQrCode('));
    expect(detailPage, contains('viewModel.openFile(filePath)'));
  });

  test('details content uses shared surfaces and semantic theme colors', () {
    expect(buildContent, contains('AppSurface('));
    expect(buildContent, contains('AppSectionHeader('));
    expect(buildContent, isNot(contains('headlineLarge')));
    expect(buildContent, isNot(contains('Colors.blue')));
    expect(
      buildContent,
      contains(
        'return Linkable(text: data, style: Theme.of(context).textTheme.bodyLarge);',
      ),
    );
  });
}
