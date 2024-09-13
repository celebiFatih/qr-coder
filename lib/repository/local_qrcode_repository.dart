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
        '''CREATE TABLE qr_codes (id INTEGER PRIMARY KEY AUTOINCREMENT, data TEXT NOT NULL, name TEXT, created_at TEXT NOT NULL)''');
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
  Future<void> deleteAllQrCodes() async {
    final db = await database;
    await db.delete('qr_codes');
  }

  @override
  Future<void> updateQRCodeName(
      String id, Map<String, dynamic> updatedData) async {
    final db = await database;
    await db.update('qr_codes', {'name': updatedData['name']},
        where: 'id = ?', whereArgs: [int.parse(id)]);
  }

  @override
  Future<List<QRCodeModel>> fetchAllQRCodes() async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('qr_codes', orderBy: 'created_at ASC');

    if (maps.isEmpty) {
      return [];
    } else {
      return List.generate(maps.length, (i) {
        return QRCodeModel.fromJson(maps[i]['id'].toString(), maps[i]);
      });
    }
  }
}
