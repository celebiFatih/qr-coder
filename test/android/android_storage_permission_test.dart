import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android manifest keeps only legacy write storage through API 28', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();

    expect(
      manifest,
      contains(
        '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" '
        'android:maxSdkVersion="28" />',
      ),
    );

    expect(
      manifest,
      isNot(contains('android.permission.READ_EXTERNAL_STORAGE')),
    );
    expect(manifest, isNot(contains('android.permission.READ_MEDIA_IMAGES')));
    expect(
      manifest,
      isNot(contains('android.permission.MANAGE_EXTERNAL_STORAGE')),
    );
  });

  test('gallery save requests storage permission only on API 28 and lower', () {
    final source = File('lib/viewmodels/qr_code_viewmodel.dart')
        .readAsStringSync();

    expect(source, contains('androidInfo.version.sdkInt <= 28'));
    expect(source, isNot(contains('androidInfo.version.sdkInt < 33')));
    expect(
      RegExp(r'Permission\.storage\.request\(\)').allMatches(source).length,
      1,
    );
  });
}
