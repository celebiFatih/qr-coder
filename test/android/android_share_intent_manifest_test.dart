import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android share target accepts only plain text', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      manifest,
      contains('<action android:name="android.intent.action.SEND"/>'),
    );
    expect(manifest, contains('<data android:mimeType="text/plain"/>'));
    expect(manifest, isNot(contains('<data android:mimeType="*/*"/>')));
  });
}
