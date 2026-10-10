import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../utils/formatters.dart';
import 'add_transaction_screen.dart';
import 'profile_screen.dart';
import 'statistics_screen.dart';
import 'transaction_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _primary = Color(0xFF1967D2);

  final _repo = TransactionRepository.instance;

  int _tab = 0;
  bool _hideBalance = false;

  void _openAdd() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: _tab >= 2
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
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              // Repository đổi => phần thân tự vẽ lại
              child: ListenableBuilder(
                listenable: _repo,
                builder: (context, _) => _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Quản lý thu chi', 'Giao dịch', 'Thống kê', 'Cá nhân'];
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
          children: const [TransactionListScreen()],
        );
      case 2:
        return const StatisticsScreen();
      case 3:
        return const ProfileScreen();
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
                    value: _repo.totalIncome,
                    color: const Color(0xFF22C55E),
                    bg: const Color(0xFFEAF7EE),
                    icon: Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _summaryCard(
                    label: 'TỔNG CHI TIÊU',
                    value: _repo.totalExpense,
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
            const TransactionListScreen(limit: 5),
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
                _hideBalance ? '••••••• đ' : formatMoney(_repo.balance),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _summaryCard({
    required String label,
    required int value,
    required Color color,
    required Color bg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
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
}
