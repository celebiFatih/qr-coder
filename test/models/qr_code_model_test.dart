import 'package:flutter_test/flutter_test.dart';
import 'package:qr_coder/models/qr_code_model.dart';

void main() {
  group('QRCodeModel', () {
    test('toJson serializes persisted fields', () {
      final model = QRCodeModel(
        id: '42',
        data: 'https://example.com',
        name: 'Example',
        createdAt: '17.08.2026 14:30',
      );

      expect(model.toJson(), <String, dynamic>{
        'name': 'Example',
        'data': 'https://example.com',
        'created_at': '17.08.2026 14:30',
      });
    });

    test('fromJson restores id and persisted fields', () {
      final model = QRCodeModel.fromJson('42', <dynamic, dynamic>{
        'name': 'Example',
        'data': 'WIFI:T:WPA;S:Test;P:secret;;',
        'created_at': '17.08.2026 14:30',
      });

      expect(model.id, '42');
      expect(model.name, 'Example');
      expect(model.data, 'WIFI:T:WPA;S:Test;P:secret;;');
      expect(model.createdAt, '17.08.2026 14:30');
    });

    test('legacy optional fields may be missing without crashing', () {
      final model = QRCodeModel.fromJson('legacy-1', <dynamic, dynamic>{
        'data': 'legacy payload',
        'name': null,
      });

      expect(model.id, 'legacy-1');
      expect(model.data, 'legacy payload');
      expect(model.name, isEmpty);
      expect(model.createdAt, isEmpty);
    });

    test('tryFromJson rejects records without a usable QR payload', () {
      expect(
        QRCodeModel.tryFromJson('missing-data', <dynamic, dynamic>{
          'name': 'Legacy',
        }),
        isNull,
      );
      expect(
        QRCodeModel.tryFromJson('wrong-type', <dynamic, dynamic>{'data': 123}),
        isNull,
      );
      expect(
        QRCodeModel.tryFromJson('empty-data', <dynamic, dynamic>{'data': ''}),
        isNull,
      );
    });

    test('fromJson reports malformed records as FormatException', () {
      expect(
        () => QRCodeModel.fromJson('bad', <dynamic, dynamic>{'data': null}),
        throwsFormatException,
      );
    });
  });
}
