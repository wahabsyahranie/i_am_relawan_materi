import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class BencanaDatabaseService {
  BencanaDatabaseService._internal();
  static final BencanaDatabaseService instance =
      BencanaDatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'iam_relawan.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          '''CREATE TABLE bencana(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, location TEXT NOT NULL, description TEXT, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, nameReporter TEXT NOT NULL, phoneNumber TEXT NOT NULL)''',
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllBencana() async {
    final db = await database;
    return db.query('bencana', orderBy: 'createdAt DESC');
  }

  Future<int> insertBencana(Map<String, dynamic> data) async {
    final db = await database;
    return db.insert('bencana', data);
  }

  Future<void> deleteBencana(int id) async {
    final db = await database;
    await db.delete('bencana', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBencana(int id, Map<String, dynamic> data) async {
    final db = await database;
    return db.update('bencana', data, where: 'id = ?', whereArgs: [id]);
  }
}
