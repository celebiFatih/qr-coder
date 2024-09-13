import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

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

  Future<int> insertQrCode(Map<String, dynamic> row) async {
    final db = await database;
    return await db.insert('qr_codes', row);
  }

  Future<int> updateQRCodeName(int id, String name) async {
    final db = await database;
    return await db.update('qr_codes', {'name': name},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllQRCodes() async {
    final db = await database;
    return await db.query('qr_codes', orderBy: 'created_at ASC');
  }

  Future<int> deleteQRCode(int id) async {
    final db = await database;
    return await db.delete('qr_codes', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllQRCodes() async {
    final db = await database;
    return await db.delete('qr_codes');
  }
}
