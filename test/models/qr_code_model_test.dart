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
  });
}
