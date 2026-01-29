import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'pos_database.db');

      final db = await openDatabase(
        path,
        version: 1,
        onCreate: _onCreate,
      );
      
      // Ensure initial data exists even if onCreate was not called (e.g. existing DB)
      await _ensureInitialData(db);
      
      return db;
    } catch (e) {
      debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          username TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          role TEXT NOT NULL,
          full_name TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          description TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE products (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          sku TEXT NOT NULL UNIQUE,
          sale_price REAL NOT NULL,
          cost_price REAL NOT NULL,
          stock INTEGER NOT NULL DEFAULT 0,
          category_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (category_id) REFERENCES categories (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE customers (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE sales (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          customer_id INTEGER,
          subtotal REAL NOT NULL,
          tax REAL NOT NULL,
          total REAL NOT NULL,
          payment_method TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES users (id),
          FOREIGN KEY (customer_id) REFERENCES customers (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE sale_details (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          sale_id INTEGER NOT NULL,
          product_id INTEGER NOT NULL,
          product_name TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          unit_price REAL NOT NULL,
          subtotal REAL NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL,
          FOREIGN KEY (sale_id) REFERENCES sales (id),
          FOREIGN KEY (product_id) REFERENCES products (id)
        )
      ''');

      // Note: _ensureInitialData will be called by _initDatabase anyway
      debugPrint('Database created successfully');
    } catch (e) {
      debugPrint('Error creating database tables: $e');
      rethrow;
    }
  }

  Future<void> _ensureInitialData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // Use ConflictAlgorithm.ignore to avoid errors if data already exists
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'role': 'Administrador',
      'full_name': 'Administrador Principal',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    await db.insert('users', {
      'username': 'cajero',
      'password': 'cajero123',
      'role': 'Cajero',
      'full_name': 'Cajero General',
      'created_at': now,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);

    // Check if categories exist before inserting to avoid duplicates if they were not unique constrained
    // But since they are not unique constrained by name (only ID), we should check count or existing names.
    // For simplicity, let's checking if table is empty for categories
    final categoriesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM categories'));
    if (categoriesCount == 0) {
      await db.insert('categories', {
        'name': 'Bebidas',
        'description': 'Bebidas y refrescos',
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('categories', {
        'name': 'Snacks',
        'description': 'Bocadillos y aperitivos',
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('categories', {
        'name': 'Electrónica',
        'description': 'Productos electrónicos',
        'created_at': now,
        'updated_at': now,
      });
    }

    final productsCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    if (productsCount == 0) {
      await db.insert('products', {
        'name': 'Coca-Cola 500ml',
        'sku': 'BEB001',
        'sale_price': 25.0,
        'cost_price': 15.0,
        'stock': 50,
        'category_id': 1,
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('products', {
        'name': 'Agua Mineral 1L',
        'sku': 'BEB002',
        'sale_price': 15.0,
        'cost_price': 8.0,
        'stock': 100,
        'category_id': 1,
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('products', {
        'name': 'Papas Fritas 150g',
        'sku': 'SNK001',
        'sale_price': 30.0,
        'cost_price': 18.0,
        'stock': 75,
        'category_id': 2,
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('products', {
        'name': 'Chocolate Bar',
        'sku': 'SNK002',
        'sale_price': 20.0,
        'cost_price': 12.0,
        'stock': 60,
        'category_id': 2,
        'created_at': now,
        'updated_at': now,
      });

      await db.insert('products', {
        'name': 'Auriculares Bluetooth',
        'sku': 'ELE001',
        'sale_price': 450.0,
        'cost_price': 300.0,
        'stock': 15,
        'category_id': 3,
        'created_at': now,
        'updated_at': now,
      });
    }

    final customersCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM customers'));
    if (customersCount == 0) {
      await db.insert('customers', {
        'name': 'Cliente General',
        'email': null,
        'phone': null,
        'created_at': now,
        'updated_at': now,
      });
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
