import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/widgets/qr_code_display.dart';

void main() {
  test('generator owns one stable repaint key for its page lifetime', () {
    final source = File('lib/views/qr_code_generator_page.dart')
        .readAsStringSync();

    expect(source, contains('final GlobalKey _repaintKey = GlobalKey();'));
    expect(
      source,
      isNot(contains('final GlobalKey repaintKey = GlobalKey();')),
    );
    expect(source, contains('repaintKey: _repaintKey'));
  });

  test('generator routes logo removal through its stable page context', () {
    final source = File('lib/views/qr_code_generator_page.dart')
        .readAsStringSync();

    expect(source, contains('Future<void> _handleRemoveLogo() async'));
    expect(source, contains('onLogoTap: _handleRemoveLogo'));
    expect(
      source,
      contains(
        'context.read<QRCodeDisplayViewModel>().promptRemoveLogo(context)',
      ),
    );
  });

  test('QRcodeDisplay accepts an owner-provided logo tap callback', () {
    void onLogoTap() {}

    final widget = QRcodeDisplay(
      data: 'generator-lifecycle-test',
      repaintKey: GlobalKey(),
      onLogoTap: onLogoTap,
    );

    expect(widget.onLogoTap, same(onLogoTap));
  });
}
