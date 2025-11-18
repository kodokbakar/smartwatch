import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class RegisterModel {
  static final RegisterModel _instance = RegisterModel._internal();
  factory RegisterModel() => _instance;
  RegisterModel._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.sql');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
          ''',
        );
      },
    );
  }

  Future<bool> usernameExists(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  Future<int> insertUser(String username, String password) async {
    final db = await database;
    return db.insert(
      'users',
      {
        'username': username,
        'password': password,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
