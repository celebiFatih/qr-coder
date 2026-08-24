import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release build loads app keep rules for R8', () {
    final appGradle = File('android/app/build.gradle').readAsStringSync();

    expect(
      appGradle,
      contains(
        "proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'",
      ),
    );
  });

  test('WorkManager Room database survives release R8 optimization', () {
    final rules = File('android/app/proguard-rules.pro').readAsStringSync();

    expect(
      rules,
      contains('-keep class androidx.work.impl.WorkDatabase_Impl { *; }'),
    );
    expect(
      rules,
      contains('-keep class * extends androidx.room.RoomDatabase { *; }'),
    );
  });

  test('scanner result label describes scanned data in English', () {
    final englishArb = File('lib/l10n/app_en.arb').readAsStringSync();

    expect(englishArb, contains('"scannerPage_scannedData": "Scanned data"'));
    expect(
      englishArb,
      isNot(contains('"scannerPage_scannedData": "Saved QR codes"')),
    );
  });
}
