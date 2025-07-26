// lib/features/pe_system/data/datasources/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/local_code_item_db.dart';

class DatabaseHelper {
  static const _databaseName = "PESystem.db";
  static const _databaseVersion = 1;
  static const tableSerialNumbers = 'serial_numbers';
  static const columnId = '_id';
  static const columnSerialNumber = 'serialNumber';
  static const columnListId = 'listId';
  static const columnIsFound = 'isFound';

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tableSerialNumbers (
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnSerialNumber TEXT NOT NULL,
            $columnListId TEXT NOT NULL,
            $columnIsFound INTEGER NOT NULL DEFAULT 0,
            UNIQUE ($columnSerialNumber, $columnListId)
          )
          ''');
  }

  Future<int> insertCode(LocalCodeItemDb code) async {
    Database db = await instance.database;
    return await db.insert(tableSerialNumbers, code.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertCodes(List<LocalCodeItemDb> codes, String listId) async {
    if (codes.isEmpty) return;
    Database db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete(
        tableSerialNumbers,
        where: '$columnListId = ?',
        whereArgs: [listId],
      );
      Batch batch = txn.batch();
      for (var code in codes) {
        batch.insert(tableSerialNumbers, code.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<LocalCodeItemDb>> getCodesByListId(String listId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSerialNumbers,
      where: '$columnListId = ?',
      whereArgs: [listId],
      orderBy: '$columnSerialNumber ASC',
    );
    return List.generate(maps.length, (i) => LocalCodeItemDb.fromMap(maps[i]));
  }

  Future<LocalCodeItemDb?> findCode(String serialNumber, String listId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSerialNumbers,
      where: '$columnSerialNumber = ? AND $columnListId = ?',
      whereArgs: [serialNumber, listId],
    );
    if (maps.isNotEmpty) {
      return LocalCodeItemDb.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateFoundStatus(String serialNumber, String listId, bool isFound) async {
    Database db = await instance.database;
    return await db.update(
      tableSerialNumbers,
      {columnIsFound: isFound ? 1 : 0},
      where: '$columnSerialNumber = ? AND $columnListId = ?',
      whereArgs: [serialNumber, listId],
    );
  }

  Future<List<LocalCodeItemDb>> getFoundCodesByListId(String listId) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableSerialNumbers,
      where: '$columnListId = ? AND $columnIsFound = ?',
      whereArgs: [listId, 1],
    );
    return List.generate(maps.length, (i) => LocalCodeItemDb.fromMap(maps[i]));
  }

  Future<int> deleteCodesByListId(String listId) async {
    Database db = await instance.database;
    return await db.delete(
      tableSerialNumbers,
      where: '$columnListId = ?',
      whereArgs: [listId],
    );
  }

  Future<void> clearAllData() async {
    Database db = await instance.database;
    await db.delete(tableSerialNumbers);
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }

  Future<int> getCodeCountByListId(String listId) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM $tableSerialNumbers WHERE $columnListId = ?', [listId])) ??
        0;
  }
}