import 'package:path/path.dart';
import 'package:qr_coder/models/qr_code_model.dart';
import 'package:qr_coder/repository/qrcode_repository.dart';
import 'package:sqflite/sqflite.dart';

class LocalQrCodeRepository implements QRCodeRepository {
  static final LocalQrCodeRepository _instance =
      LocalQrCodeRepository._internal();
  static Database? _database;

  factory LocalQrCodeRepository() => _instance;

  LocalQrCodeRepository._internal();

  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'qrcoder.db');
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  void _createDatabase(Database db, int version) async {
    await db.execute(
      '''CREATE TABLE qr_codes (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, name TEXT, created_at TEXT NOT NULL)''',
    );
  }

  @override
  Future<void> insertQrCode(QRCodeModel qrCode) async {
    final db = await database;
    await db.insert('qr_codes', qrCode.toJson());
  }

  @override
  Future<void> deleteQrCode(String id) async {
    final db = await database;
    await db.delete('qr_codes', where: 'id = ?', whereArgs: [int.parse(id)]);
  }

  @override
  Future<void> deleteQrCodes(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }

    // Parse every id before touching the database so malformed input cannot
    // leave a partially deleted local selection.
    final parsedIds = ids.map(int.parse).toList(growable: false);
    final placeholders = List.filled(parsedIds.length, '?').join(', ');

    final db = await database;
    await db.delete(
      'qr_codes',
      where: 'id IN ($placeholders)',
      whereArgs: parsedIds,
    );
  }

  @override
  Future<void> deleteAllQrCodes() async {
    final db = await database;
    await db.delete('qr_codes');
  }

  @override
  Future<void> updateQRCodeName(
    String id,
    Map<String, dynamic> updatedData,
  ) async {
    final db = await database;
    await db.update(
      'qr_codes',
      {'name': updatedData['name']},
      where: 'id = ?',
      whereArgs: [int.parse(id)],
    );
  }

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async {
    final db = await database;
    final maps = await db.query('qr_codes', orderBy: 'created_at ASC');

    final qrCodes = <QRCodeModel>[];

    for (final row in maps) {
      final rawId = row['id'];
      if (rawId == null) {
        continue;
      }

      final qrCode = QRCodeModel.tryFromJson(rawId.toString(), row);
      if (qrCode != null) {
        qrCodes.add(qrCode);
      }
    }

    return qrCodes;
  }
}
