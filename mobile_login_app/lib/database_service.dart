import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final fullPath = path.join(dbPath, filePath);

    return openDatabase(
      fullPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_code TEXT,
        display_name TEXT,
        email TEXT,
        employee_code TEXT,
        company_code TEXT
      )
    ''');
  }

  Future<void> insertUser(Map<String, dynamic> user) async {
    final db = await instance.database;

    await db.insert('user', user);
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final db = await instance.database;

    return await db.query('user');
  }
}
