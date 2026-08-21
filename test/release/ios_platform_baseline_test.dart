import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS project uses the supported deployment baseline', () {
    final project = File('ios/Runner.xcodeproj/project.pbxproj')
        .readAsStringSync();

    final targets = RegExp(r'IPHONEOS_DEPLOYMENT_TARGET = ([0-9.]+);')
        .allMatches(project)
        .map((match) => match.group(1))
        .toList();

    expect(targets, isNotEmpty);
    expect(targets.every((target) => target == '15.0'), isTrue);
  });

  test('Flutter framework metadata matches the iOS deployment baseline', () {
    final frameworkInfo = File('ios/Flutter/AppFrameworkInfo.plist')
        .readAsStringSync();

    expect(
      frameworkInfo,
      contains('<key>MinimumOSVersion</key>\n  <string>15.0</string>'),
    );
  });

  test('iOS declares photo-library permissions for gallery saving', () {
    final infoPlist = File('ios/Runner/Info.plist').readAsStringSync();

    expect(infoPlist, contains('NSPhotoLibraryAddUsageDescription'));
    expect(infoPlist, contains('NSPhotoLibraryUsageDescription'));
    expect(
      infoPlist,
      contains(
        'QR Coder needs permission to save generated QR code images '
        'to your photo library.',
      ),
    );
  });

  test('gallery save does not request legacy storage permission on iOS', () {
    final source = File('lib/viewmodels/qr_code_viewmodel.dart')
        .readAsStringSync();

    expect(source, contains('if (Platform.isAndroid)'));
    expect(
      RegExp(r'Permission\.storage\.request\(\)').allMatches(source).length,
      1,
    );
  });
}
