import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String repository;

  setUpAll(() {
    repository = File('lib/repository/local_qrcode_repository.dart')
        .readAsStringSync();
  });

  test('local QR database keeps the established file and schema contract', () {
    expect(repository, contains("join(dbPath, 'qrcoder.db')"));
    expect(repository, contains('openDatabase(path, version: 1'));
    expect(repository, contains('CREATE TABLE qr_codes'));
    expect(repository, contains('id INTEGER PRIMARY KEY AUTOINCREMENT'));
    expect(repository, contains('data TEXT NOT NULL'));
    expect(repository, contains('name TEXT'));
    expect(repository, contains('created_at TEXT NOT NULL'));
  });

  test('local QR CRUD keeps parameterized identifiers', () {
    expect(repository, contains("where: 'id = ?'"));
    expect(repository, contains('whereArgs: [int.parse(id)]'));
    expect(repository, contains("where: 'id IN (\$placeholders)'"));
    expect(repository, contains('whereArgs: parsedIds'));
  });

  test('selected delete validates every id before touching the database', () {
    final parseIndex = repository.indexOf(
      'final parsedIds = ids.map(int.parse).toList(growable: false);',
    );
    final databaseIndex = repository.indexOf(
      'final db = await database;',
      parseIndex,
    );

    expect(parseIndex, greaterThanOrEqualTo(0));
    expect(databaseIndex, greaterThan(parseIndex));
  });

  test('local fetch keeps deterministic ordering and malformed-row guard', () {
    expect(repository, contains("orderBy: 'created_at ASC'"));
    expect(repository, contains('QRCodeModel.tryFromJson'));
    expect(repository, contains('if (qrCode != null)'));
  });
}
