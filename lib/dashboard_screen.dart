import 'package:flutter/material.dart';
import 'add_edit_transaction_screen.dart';

/// Model 1 giao dịch (lưu tạm trong bộ nhớ, chưa dùng database)
class TransactionItem {
  final String id;
  final bool isExpense;
  final String category;
  final int amount; // luôn là số dương
  final String date; // dd/mm/yyyy
  final String note;

  const TransactionItem({
    required this.id,
    required this.isExpense,
    required this.category,
    required this.amount,
    required this.date,
    required this.note,
  });

  /// Chuyển từ Map (kết quả trả về của màn hình Thêm/Sửa) sang model
  factory TransactionItem.fromMap(Map<String, dynamic> m, {String? id}) {
    final digits = (m['amount']?.toString() ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    return TransactionItem(
      id: id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      isExpense: m['isExpense'] ?? true,
      category: m['category']?.toString() ?? 'Khác',
      amount: int.tryParse(digits) ?? 0,
      date: m['date']?.toString() ?? '',
      note: m['note']?.toString() ?? '',
    );
  }

  /// Chuyển sang Map để truyền vào AddEditTransactionScreen(initialData: ...)
  Map<String, dynamic> toMap() => {
        'isExpense': isExpense,
        'category': category,
        'amount': amount.toString(),
        'date': date,
        'note': note,
      };
}

/// Màu + icon theo tên danh mục (khớp với màn hình Thêm/Sửa)
class _CatStyle {
  final IconData icon;
  final Color color;
  const _CatStyle(this.icon, this.color);
}

_CatStyle _styleOf(TransactionItem t) {
  if (!t.isExpense) return const _CatStyle(Icons.savings, Color(0xFF22C55E));
  switch (t.category) {
    case 'Ăn uống':
      return const _CatStyle(Icons.restaurant, Color(0xFFF59E0B));
    case 'Di chuyển':
      return const _CatStyle(Icons.directions_bus, Color(0xFF3B82F6));
    case 'Mua sắm':
      return const _CatStyle(Icons.shopping_bag, Color(0xFFEC4899));
    case 'Hóa đơn':
      return const _CatStyle(Icons.receipt_long, Color(0xFF10B981));
    default:
      return const _CatStyle(Icons.more_horiz, Color(0xFF64748B));
  }
}

String formatMoney(int v) {
  final s = v.abs().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
  return '$s đ';
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _primary = Color(0xFF1967D2);

  int _tab = 0;
  bool _hideBalance = false;

  // Dữ liệu mẫu giống hình. Muốn bắt đầu trống thì đổi thành: [].
  final List<TransactionItem> _items = [
    const TransactionItem(
        id: '1', isExpense: true, category: 'Ăn uống', amount: 50000, date: '03/09/2024', note: 'Ăn trưa'),
    const TransactionItem(
        id: '2', isExpense: true, category: 'Di chuyển', amount: 100000, date: '03/09/2024', note: 'Xăng xe'),
    const TransactionItem(
        id: '3', isExpense: false, category: 'Thu nhập', amount: 8000000, date: '01/09/2024', note: 'Lương tháng 9'),
    const TransactionItem(
        id: '4', isExpense: true, category: 'Mua sắm', amount: 300000, date: '31/08/2024', note: 'Mua sắm'),
    const TransactionItem(
        id: '5', isExpense: true, category: 'Hóa đơn', amount: 500000, date: '30/08/2024', note: 'Học phí'),
  ];

  int get _totalIncome =>
      _items.where((t) => !t.isExpense).fold(0, (s, t) => s + t.amount);
  int get _totalExpense =>
      _items.where((t) => t.isExpense).fold(0, (s, t) => s + t.amount);
  int get _balance => _totalIncome - _totalExpense;

  // ---- Thêm giao dịch ----
  Future<void> _openAdd() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => const AddEditTransactionScreen()),
    );
    if (result == null) return;
    final item = TransactionItem.fromMap(result);
    if (item.amount <= 0) {
      _toast('Số tiền không hợp lệ, giao dịch chưa được lưu');
      return;
    }
    setState(() => _items.insert(0, item));
  }

  // ---- Sửa giao dịch ----
  Future<void> _openEdit(TransactionItem old) async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => AddEditTransactionScreen(initialData: old.toMap()),
      ),
    );
    if (result == null) return;
    final updated = TransactionItem.fromMap(result, id: old.id);
    if (updated.amount <= 0) {
      _toast('Số tiền không hợp lệ, giao dịch chưa được cập nhật');
      return;
    }
    setState(() {
      final i = _items.indexWhere((t) => t.id == old.id);
      if (i != -1) _items[i] = updated;
    });
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _tab == 2
          ? null
          : FloatingActionButton(
              onPressed: _openAdd,
              backgroundColor: _primary,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, size: 28),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (i) => setState(() => _tab = i),
        backgroundColor: Colors.white,
        selectedItemColor: _primary,
        unselectedItemColor: _ink,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Giao dịch'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Thống kê'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Quản lý thu chi', 'Giao dịch', 'Thống kê'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          const Icon(Icons.menu, color: _ink),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              titles[_tab],
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: _ink),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_none, color: _ink),
              Positioned(
                right: 1,
                top: 1,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                      color: Color(0xFFEF4444), shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_tab) {
      case 1:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [_transactionList(_items)],
        );
      case 2:
        return const Center(
          child: Text('Màn hình Thống kê (sẽ làm ở buổi sau)',
              style: TextStyle(color: _muted)),
        );
      default:
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
          children: [
            _balanceCard(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _summaryCard(
                    label: 'TỔNG THU NHẬP',
                    value: _totalIncome,
                    color: const Color(0xFF22C55E),
                    bg: const Color(0xFFEAF7EE),
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    label: 'TỔNG CHI TIÊU',
                    value: _totalExpense,
                    color: const Color(0xFFEF4444),
                    bg: const Color(0xFFFDECEC),
                    icon: Icons.arrow_upward,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text('Giao dịch gần đây',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                ),
                GestureDetector(
                  onTap: () => setState(() => _tab = 1),
                  child: const Text('Xem tất cả',
                      style: TextStyle(
                          fontSize: 12,
                          color: _primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _transactionList(_items.take(5).toList()),
          ],
        );
    }
  }

  Widget _balanceCard() {
    return Container(
      height: 135,
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Hình ví trang trí bên phải
          Positioned(
            right: 0,
            top: 8,
            child: Icon(Icons.account_balance_wallet,
                size: 64, color: Colors.white.withOpacity(0.85)),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('SỐ DƯ HIỆN TẠI',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _hideBalance = !_hideBalance),
                    child: Icon(
                        _hideBalance ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                        size: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _hideBalance
                    ? '••••••• đ'
                    : '${_balance < 0 ? '-' : ''}${formatMoney(_balance)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          // Chấm chỉ trang
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _dot(true),
                _dot(false),
                _dot(false),
                _dot(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot(bool active) => Container(
        width: active ? 12 : 4,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(active ? 1 : 0.5),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _summaryCard({
    required String label,
    required int value,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 9, color: _muted)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(formatMoney(value),
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: color)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionList(List<TransactionItem> list) {
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text('Chưa có giao dịch nào.\nBấm nút + để thêm.',
              textAlign: TextAlign.center, style: TextStyle(color: _muted)),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < list.length; i++) ...[
            _transactionTile(list[i]),
            if (i != list.length - 1)
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ],
        ],
      ),
    );
  }

  Widget _transactionTile(TransactionItem t) {
    final style = _styleOf(t);
    final amountColor =
        t.isExpense ? const Color(0xFFEF4444) : const Color(0xFF16A34A);
    final title = t.note.trim().isEmpty ? t.category : t.note;

    return InkWell(
      onTap: () => _openEdit(t), // bấm vào => mở màn hình Sửa giao dịch
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: style.color,
              child: Icon(style.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                  const SizedBox(height: 4),
                  Text(t.category,
                      style: const TextStyle(fontSize: 10, color: _muted)),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(t.date,
                  style: const TextStyle(fontSize: 10, color: _muted)),
            ),
            Text(
              '${t.isExpense ? '-' : '+'}${formatMoney(t.amount)}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: amountColor),
            ),
          ],
        ),
      ),
    );
  }
}
