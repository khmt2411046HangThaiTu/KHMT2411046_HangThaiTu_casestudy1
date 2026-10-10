import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';
import '../models/transaction_model.dart';

/// Tầng repository: cầu nối giữa giao diện (screens) và database.
/// - Giữ bản sao danh sách giao dịch trong bộ nhớ để màn hình đọc nhanh.
/// - Mọi thay đổi đều ghi xuống database rồi báo cho giao diện vẽ lại.
class TransactionRepository extends ChangeNotifier {
  TransactionRepository._();

  static final TransactionRepository instance = TransactionRepository._();

  final DatabaseHelper _db = DatabaseHelper.instance;

  List<TransactionModel> _items = [];

  /// Danh sách giao dịch (mới nhất trước)
  List<TransactionModel> get all => List.unmodifiable(_items);

  int get totalIncome =>
      _items.where((t) => !t.isExpense).fold(0, (s, t) => s + t.amount);

  int get totalExpense =>
      _items.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);

  int get balance => totalIncome - totalExpense;

  /// Đọc toàn bộ giao dịch từ database (gọi 1 lần khi mở app)
  Future<void> load() async {
    _items = await _db.getAllTransactions();
    notifyListeners();
  }

  /// Thêm giao dịch mới (id được tạo tự động)
  Future<void> add(TransactionModel t) async {
    await _db.insertTransaction(t.copyWith(id: _newId()));
    await load();
  }

  /// Cập nhật giao dịch đã có (tìm theo id)
  Future<void> update(TransactionModel t) async {
    await _db.updateTransaction(t);
    await load();
  }

  /// Xóa giao dịch theo id
  Future<void> delete(String id) async {
    await _db.deleteTransaction(id);
    await load();
  }

  /// Tổng chi tiêu theo từng danh mục trong khoảng [from, to)
  Map<String, int> expenseByCategory({
    required DateTime from,
    required DateTime to,
  }) {
    final result = <String, int>{};
    for (final t in _items) {
      if (!t.isExpense) continue;
      if (t.date.isBefore(from) || !t.date.isBefore(to)) continue;
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
