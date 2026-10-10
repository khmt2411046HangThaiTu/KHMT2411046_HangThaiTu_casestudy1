import 'package:flutter/material.dart';

/// Danh mục chi tiêu / thu nhập (tên + icon + màu)
class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<TransactionCategory> expenseCategories = [
    TransactionCategory(name: 'Ăn uống', icon: Icons.restaurant, color: Color(0xFFF59E0B)),
    TransactionCategory(name: 'Di chuyển', icon: Icons.directions_bus, color: Color(0xFF3B82F6)),
    TransactionCategory(name: 'Mua sắm', icon: Icons.shopping_bag, color: Color(0xFFEC4899)),
    TransactionCategory(name: 'Hóa đơn', icon: Icons.receipt_long, color: Color(0xFF10B981)),
    TransactionCategory(name: 'Khác', icon: Icons.more_horiz, color: Color(0xFF64748B)),
  ];

  static const List<TransactionCategory> incomeCategories = [
    TransactionCategory(name: 'Thu nhập', icon: Icons.savings, color: Color(0xFF22C55E)),
    TransactionCategory(name: 'Lương', icon: Icons.payments, color: Color(0xFF16A34A)),
    TransactionCategory(name: 'Thưởng', icon: Icons.card_giftcard, color: Color(0xFF0EA5E9)),
  ];

  /// Danh sách danh mục theo loại giao dịch
  static List<TransactionCategory> forType(bool isExpense) =>
      isExpense ? expenseCategories : incomeCategories;

  /// Tìm danh mục theo tên; không thấy thì trả về danh mục mặc định của loại đó
  static TransactionCategory find(String name, {required bool isExpense}) {
    final list = forType(isExpense);
    return list.firstWhere(
      (c) => c.name == name,
      orElse: () => isExpense ? list.last : list.first,
    );
  }
}
