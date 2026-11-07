import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _db;

  static Future<Database> get database async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final folder = await getDatabasesPath();
    final path = join(folder, 'tailor_shop.db');

    return openDatabase(
      path,
      version: 2, 
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        address TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements (
        customerId TEXT PRIMARY KEY,
        kameezLength REAL, chest REAL, waist REAL, shoulder REAL,
        sleeve REAL, neck REAL, daman REAL,
        shalwarLength REAL, shalwarWaist REAL, hip REAL, pancha REAL,
        notes TEXT,
        collarStyle TEXT,
        damanType TEXT,
        sidePockets INTEGER,
        frontPocket INTEGER,
        shalwarPocket INTEGER
      )
    ''');   
    await db.execute('''
      CREATE TABLE orders (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        dressType TEXT NOT NULL,
        fabric TEXT NOT NULL,
        price REAL NOT NULL,
        advance REAL NOT NULL,
        deliveryDate TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');
  }

  
  static Future<bool> _hasColumn(
    Database db,
    String table,
    String column,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)'); 
    return info.any((row) => row['name'] == column);
  }

  
  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      if (!await _hasColumn(db, 'orders', 'orderNumber')) {
        await db.execute(
          'ALTER TABLE orders ADD COLUMN orderNumber INTEGER NOT NULL DEFAULT 0',
        );
      }
      await db.execute(
        'UPDATE orders SET orderNumber = rowid WHERE orderNumber = 0',
      );
    }
  }

}