import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';

/// Tầng database: chỉ làm việc với SQLite (tạo bảng, truy vấn SQL).
/// Không chứa logic tính toán hay giao diện.
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _dbName = 'expense_manager.db';
  static const _dbVersion = 1;
  static const tableTransactions = 'transactions';

  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableTransactions (
            id          TEXT PRIMARY KEY,
            is_expense  INTEGER NOT NULL,
            category    TEXT    NOT NULL,
            amount      INTEGER NOT NULL,
            date        INTEGER NOT NULL,
            note        TEXT    NOT NULL DEFAULT ''
          )
        ''');
      },
    );
  }

  /// Giao dịch mới nhất trước (cùng ngày thì cái thêm sau đứng trên)
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final rows =
        await db.query(tableTransactions, orderBy: 'date DESC, rowid DESC');
    return rows.map(TransactionModel.fromMap).toList();
  }

  Future<void> insertTransaction(TransactionModel t) async {
    final db = await database;
    await db.insert(tableTransactions, t.toMap());
  }

  Future<void> updateTransaction(TransactionModel t) async {
    final db = await database;
    await db.update(
      tableTransactions,
      t.toMap(),
      where: 'id = ?',
      whereArgs: [t.id],
    );
  }

  Future<void> deleteTransaction(String id) async {
    final db = await database;
    await db.delete(tableTransactions, where: 'id = ?', whereArgs: [id]);
  }
}
