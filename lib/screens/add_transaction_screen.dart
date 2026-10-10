import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_category.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';

/// Màn hình Thêm giao dịch
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(
      title: 'Thêm giao dịch',
      onSave: TransactionRepository.instance.add,
    );
  }
}

/// Form dùng chung cho Thêm / Sửa giao dịch.
/// - [initial] == null => form trống (ngày mặc định là hôm nay)
/// - [initial] != null => điền sẵn dữ liệu
/// Bấm "Lưu" => kiểm tra hợp lệ, gọi [onSave] rồi đóng màn hình.
class TransactionFormScreen extends StatefulWidget {
  final String title;
  final TransactionModel? initial;
  final Future<void> Function(TransactionModel) onSave;

  const TransactionFormScreen({
    super.key,
    required this.title,
    required this.onSave,
    this.initial,
  });

  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  // true = Chi tiêu, false = Thu nhập
  bool isExpense = true;
  late TransactionCategory selectedCategory;
  late DateTime selectedDate;
  String? amountError;

  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      isExpense = t.isExpense;
      selectedCategory =
          TransactionCategory.find(t.category, isExpense: t.isExpense);
      selectedDate = t.date;
      amountController.text = t.amount.toString();
      noteController.text = t.note;
    } else {
      selectedCategory = TransactionCategory.forType(isExpense).first;
      selectedDate = DateTime.now();
    }
    dateController.text = formatDate(selectedDate);
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  /// Đổi loại Chi tiêu / Thu nhập => đổi danh mục cho phù hợp
  void _setType(bool expense) {
    setState(() {
      isExpense = expense;
      final list = TransactionCategory.forType(expense);
      if (!list.any((c) => c.name == selectedCategory.name)) {
        selectedCategory = list.first;
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dateController.text = formatDate(picked);
      });
    }
  }

  Future<void> _save() async {
    final digits = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final amount = int.tryParse(digits) ?? 0;
    if (amount <= 0) {
      setState(() => amountError = 'Vui lòng nhập số tiền hợp lệ');
      return;
    }
    await widget.onSave(
      TransactionModel(
        id: widget.initial?.id ?? '',
        isExpense: isExpense,
        category: selectedCategory.name,
        amount: amount,
        date: selectedDate,
        note: noteController.text.trim(),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  InputDecoration _decoration({
    String? hint,
    String? suffixText,
    Widget? suffixIcon,
    String? error,
  }) {
    const borderColor = Color(0xFFE2E8F0);
    OutlineInputBorder border(Color c) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      suffixText: suffixText,
      suffixIcon: suffixIcon,
      errorText: error,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border(borderColor),
      enabledBorder: border(borderColor),
      focusedBorder: border(const Color(0xFF1967D2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const labelColor = Color(0xFF0F172A);
    const hintColor = Color(0xFF94A3B8);
    const borderColor = Color(0xFFE2E8F0);
    const expenseColor = Color(0xFFEF4444);
    const primaryBlue = Color(0xFF1967D2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: labelColor, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Toggle Chi tiêu / Thu nhập ---
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TabButton(
                        label: 'Chi tiêu',
                        selected: isExpense,
                        selectedColor: expenseColor,
                        onTap: () => _setType(true),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Thu nhập',
                        selected: !isExpense,
                        selectedColor: primaryBlue,
                        onTap: () => _setType(false),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- Danh mục ---
              const _FieldLabel('Danh mục'),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showModalBottomSheet<TransactionCategory>(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (_) => _CategoryPicker(
                      categories: TransactionCategory.forType(isExpense),
                    ),
                  );
                  if (picked != null) {
                    setState(() => selectedCategory = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: selectedCategory.color.withOpacity(0.15),
                        child: Icon(selectedCategory.icon,
                            size: 16, color: selectedCategory.color),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          selectedCategory.name,
                          style: const TextStyle(fontSize: 15, color: labelColor),
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down, color: hintColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Số tiền ---
              const _FieldLabel('Số tiền'),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                onChanged: (_) {
                  if (amountError != null) setState(() => amountError = null);
                },
                style: const TextStyle(fontSize: 15, color: labelColor),
                decoration: _decoration(
                  hint: 'Nhập số tiền',
                  suffixText: 'đ',
                  error: amountError,
                ),
              ),
              const SizedBox(height: 20),

              // --- Ngày giao dịch ---
              const _FieldLabel('Ngày giao dịch'),
              const SizedBox(height: 8),
              TextField(
                controller: dateController,
                readOnly: true,
                onTap: _pickDate,
                style: const TextStyle(fontSize: 15, color: labelColor),
                decoration: _decoration(
                  hint: 'dd/mm/yyyy',
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: hintColor),
                ),
              ),
              const SizedBox(height: 20),

              // --- Ghi chú ---
              const _FieldLabel('Ghi chú'),
              const SizedBox(height: 8),
              TextField(
                controller: noteController,
                maxLines: 2,
                style: const TextStyle(fontSize: 15, color: labelColor),
                decoration: _decoration(hint: 'Nhập ghi chú (tùy chọn)'),
              ),
              const SizedBox(height: 32),

              // --- Nút Lưu ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lưu',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0F172A),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  const _TabButton({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  final List<TransactionCategory> categories;
  const _CategoryPicker({required this.categories});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chọn danh mục',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...categories.map(
              (c) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: c.color.withOpacity(0.15),
                  child: Icon(c.icon, color: c.color, size: 18),
                ),
                title: Text(c.name),
                onTap: () => Navigator.of(context).pop(c),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
