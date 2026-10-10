/// Model 1 giao dịch
class TransactionModel {
  final String id;
  final bool isExpense; // true = Chi tiêu, false = Thu nhập
  final String category;
  final int amount; // luôn là số dương
  final DateTime date;
  final String note;

  const TransactionModel({
    required this.id,
    required this.isExpense,
    required this.category,
    required this.amount,
    required this.date,
    this.note = '',
  });

  /// Đọc 1 dòng từ bảng database => model
  factory TransactionModel.fromMap(Map<String, Object?> m) => TransactionModel(
        id: m['id'] as String,
        isExpense: (m['is_expense'] as int) == 1,
        category: m['category'] as String,
        amount: m['amount'] as int,
        date: DateTime.fromMillisecondsSinceEpoch(m['date'] as int),
        note: (m['note'] as String?) ?? '',
      );

  /// Model => 1 dòng để ghi vào bảng database
  Map<String, Object?> toMap() => {
        'id': id,
        'is_expense': isExpense ? 1 : 0,
        'category': category,
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
        'note': note,
      };

  TransactionModel copyWith({
    String? id,
    bool? isExpense,
    String? category,
    int? amount,
    DateTime? date,
    String? note,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        isExpense: isExpense ?? this.isExpense,
        category: category ?? this.category,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        note: note ?? this.note,
      );
}
