import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/utils/qr_code_render_utils.dart';
import 'package:qr_coder/views/qr_code_list_page.dart';

void main() {
  test('oversized legacy payload is rejected before widget rendering', () {
    final legacyOversizedData = 'x' * 10000;

    expect(QRCodeRenderUtils.canRender(legacyOversizedData), isFalse);
  });

  testWidgets('preview uses a safe fallback when QR data cannot be rendered', (
    tester,
  ) async {
    // Large enough to exceed normal QR payload capacity in the renderer.
    final legacyOversizedData = 'x' * 10000;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: QrCodePreviewImage(data: legacyOversizedData)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
  });
}
