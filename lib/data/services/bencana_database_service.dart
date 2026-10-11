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
          '''CREATE TABLE bencana(id TEXT PRIMARY KEY, name TEXT NOT NULL, location TEXT NOT NULL, description TEXT, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL, nameReporter TEXT NOT NULL, phoneNumber TEXT NOT NULL, isSynced INTEGER NOT NULL DEFAULT 0, isDeleted INTEGER NOT NULL DEFAULT 0)''',
        );
      },
    );
  }

  // Update method, tambahkan filter isDeleted, berfungsi untuk data yang sudah di softdelete tidak tampil di ui
  Future<List<Map<String, dynamic>>> getAllBencana() async {
    final db = await database;
    return db.query(
      'bencana',
      where: 'isDeleted = ?',
      whereArgs: [0],
      orderBy: 'createdAt DESC',
    );
  }

  Future<void> insertBencana(Map<String, dynamic> data) async {
    final db = await database;
    await db.insert('bencana', data);
  }

  Future<void> updateBencana(String id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update('bencana', data, where: 'id = ?', whereArgs: [id]);
  }

  //Method baru, untuk menyaring semua baris, digunakan untuk mencari tahu apakah id sudah ada didatabase SQLite
  Future<List<Map<String, dynamic>>> getAllBencanaRaw() async {
    final db = await database;
    return db.query('bencana');
  }

  // Method baru, untuk mengambil semua baris yang belum tersinkron
  Future<List<Map<String, dynamic>>> getUnsyncedBencana() async {
    final db = await database;
    return db.query('bencana', where: 'isSynced = ?', whereArgs: [0]);
  }

  // Method baru, untuk hapus data secara permanen
  Future<void> hardDeleteBencana(String id) async {
    final db = await database;
    await db.delete('bencana', where: 'id = ?', whereArgs: [id]);
  }

  // Ganti method deleteBencana menjadi soft delete (hapus method delete pada minggu sebelumnya)
  Future<void> deleteBencana(String id) async {
    final db = await database;
    await db.update(
      'bencana',
      {'isDeleted': 1, 'isSynced': 0, 'updatedAt': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
