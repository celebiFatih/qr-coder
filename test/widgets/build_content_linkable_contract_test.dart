import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;

  setUpAll(() {
    source = File('lib/widgets/build_content.dart').readAsStringSync();
  });

  test('non-Wi-Fi QR content keeps Linkable rendering', () {
    expect(source, contains("import 'package:linkable/linkable.dart';"));
    expect(source, contains('return Linkable('));
    expect(source, contains('style: theme.textTheme.bodyLarge'));
    expect(source, contains('textColor: scheme.onSurface'));
    expect(source, contains('linkColor: scheme.primary'));
  });

  test('Wi-Fi QR content bypasses Linkable and keeps dedicated handling', () {
    final wifiBranch = source.indexOf('if (_isWifi(data))');
    final wifiReturn = source.indexOf(
      'return _buildWifi(context, data);',
      wifiBranch,
    );
    final linkableReturn = source.indexOf('return Linkable(', wifiBranch);

    expect(wifiBranch, greaterThanOrEqualTo(0));
    expect(wifiReturn, greaterThan(wifiBranch));
    expect(linkableReturn, greaterThan(wifiReturn));
  });

  test('Wi-Fi parser keeps optional hidden-network field support', () {
    expect(
      source,
      contains(
        r"r'^WIFI:T:(WPA|WEP|nopass);S:[^;]+;P:[^;]*;(H:(true|false);)?;$'",
      ),
    );
    expect(
      source,
      contains("_valueForPrefix(parts, 'H:', defaultValue: 'false')"),
    );
  });
}
