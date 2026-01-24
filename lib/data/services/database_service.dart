// File: database_service.dart
// Service untuk operasi database SQLite

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/prediction_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  static const String _tableName = 'prediction_sessions';
  static const int _dbVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'random_forest_bbj.db');
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        flag TEXT NOT NULL,
        tanggal_prediksi TEXT NOT NULL,
        nasabah_data TEXT NOT NULL,
        akurasi REAL NOT NULL,
        created_by TEXT DEFAULT '',
        assigned_user_ids TEXT DEFAULT '[]',
        comments TEXT DEFAULT '[]'
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for version 2
      await db.execute('ALTER TABLE $_tableName ADD COLUMN created_by TEXT DEFAULT ""');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN assigned_user_ids TEXT DEFAULT "[]"');
      await db.execute('ALTER TABLE $_tableName ADD COLUMN comments TEXT DEFAULT "[]"');
    }
  }

  Future<String> insertSession(PredictionSessionModel session) async {
    final db = await database;
    await db.insert(
      _tableName,
      session.toDbMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return session.id;
  }

  Future<List<PredictionSessionModel>> getAllSessions() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'tanggal_prediksi DESC',
    );
    return maps.map((map) => PredictionSessionModel.fromDbMap(map)).toList();
  }

  Future<PredictionSessionModel?> getSessionById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return PredictionSessionModel.fromDbMap(maps.first);
  }

  Future<int> deleteSession(String id) async {
    final db = await database;
    return await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllSessions() async {
    final db = await database;
    return await db.delete(_tableName);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
