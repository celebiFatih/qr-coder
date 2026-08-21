import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android plugin baseline supports modern plus plugins', () {
    final settings = File('android/settings.gradle').readAsStringSync();
    final wrapper = File('android/gradle/wrapper/gradle-wrapper.properties')
        .readAsStringSync();
    final appGradle = File('android/app/build.gradle').readAsStringSync();

    expect(
      settings,
      contains('id "com.android.application" version "8.12.1" apply false'),
    );
    expect(
      settings,
      contains(
        'id "org.jetbrains.kotlin.android" version "2.3.20" apply false',
      ),
    );
    expect(wrapper, contains('gradle-8.14.5-all.zip'));
    expect(appGradle, contains('sourceCompatibility JavaVersion.VERSION_17'));
    expect(appGradle, contains('targetCompatibility JavaVersion.VERSION_17'));
    expect(appGradle, contains('jvmToolchain(17)'));
    expect(appGradle, contains('compileSdk  36'));
    expect(appGradle, contains('targetSdk  36'));
  });
}
