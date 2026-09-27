import 'package:flutter/material.dart';

/// Model đơn giản cho 1 danh mục chi tiêu / thu nhập
class TransactionCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TransactionCategory({
    required this.name,
    required this.icon,
    required this.color,
  });
}

/// Màn hình Thêm / Sửa giao dịch
/// - Nếu [initialData] == null  => hiển thị "Thêm giao dịch"
/// - Nếu [initialData] != null  => hiển thị "Sửa giao dịch" và điền sẵn dữ liệu
class AddEditTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const AddEditTransactionScreen({super.key, this.initialData});

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  // true = Chi tiêu, false = Thu nhập
  bool isExpense = true;

  final List<TransactionCategory> categories = const [
    TransactionCategory(
      name: 'Ăn uống',
      icon: Icons.restaurant,
      color: Color(0xFFF59E0B),
    ),
    TransactionCategory(
      name: 'Di chuyển',
      icon: Icons.directions_bus,
      color: Color(0xFF3B82F6),
    ),
    TransactionCategory(
      name: 'Mua sắm',
      icon: Icons.shopping_bag,
      color: Color(0xFFEC4899),
    ),
    TransactionCategory(
      name: 'Hóa đơn',
      icon: Icons.receipt_long,
      color: Color(0xFF10B981),
    ),
    TransactionCategory(
      name: 'Khác',
      icon: Icons.more_horiz,
      color: Color(0xFF64748B),
    ),
  ];

  late TransactionCategory selectedCategory;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  bool get isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    selectedCategory = categories.first;

    final data = widget.initialData;
    if (data != null) {
      isExpense = data['isExpense'] ?? true;
      amountController.text = data['amount']?.toString() ?? '';
      dateController.text = data['date']?.toString() ?? '';
      noteController.text = data['note']?.toString() ?? '';
      final catName = data['category'];
      if (catName != null) {
        selectedCategory = categories.firstWhere(
          (c) => c.name == catName,
          orElse: () => categories.first,
        );
      }
    } else {
      final now = DateTime.now();
      dateController.text =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    }
  }

  @override
  void dispose() {
    amountController.dispose();
    dateController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        dateController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  void _save() {
    final result = {
      'isExpense': isExpense,
      'category': selectedCategory.name,
      'amount': amountController.text,
      'date': dateController.text,
      'note': noteController.text,
    };
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Colors.white;
    const labelColor = Color(0xFF0F172A);
    const hintColor = Color(0xFF94A3B8);
    const borderColor = Color(0xFFE2E8F0);
    const expenseColor = Color(0xFFEF4444); // đỏ - Chi tiêu
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
          isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch',
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
                        onTap: () => setState(() => isExpense = true),
                      ),
                    ),
                    Expanded(
                      child: _TabButton(
                        label: 'Thu nhập',
                        selected: !isExpense,
                        selectedColor: primaryBlue,
                        onTap: () => setState(() => isExpense = false),
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
                    builder: (ctx) => _CategoryPicker(categories: categories),
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
                style: const TextStyle(fontSize: 15, color: labelColor),
                decoration: InputDecoration(
                  hintText: 'Nhập số tiền',
                  hintStyle: const TextStyle(color: hintColor),
                  suffixText: 'đ',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryBlue),
                  ),
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
                decoration: InputDecoration(
                  hintText: 'dd/mm/yyyy',
                  hintStyle: const TextStyle(color: hintColor),
                  suffixIcon: const Icon(Icons.calendar_today_outlined,
                      size: 18, color: hintColor),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryBlue),
                  ),
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
                decoration: InputDecoration(
                  hintText: 'Nhập ghi chú (tùy chọn)',
                  hintStyle: const TextStyle(color: hintColor),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryBlue),
                  ),
                ),
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
