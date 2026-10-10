import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/transaction_category.dart';
import '../repositories/transaction_repository.dart';
import '../utils/formatters.dart';

/// Màn hình Thống kê: biểu đồ tròn chi tiêu theo danh mục.
/// Không có Scaffold riêng để nhúng vào tab của Dashboard.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _primary = Color(0xFF1967D2);

  static const _periods = ['Tháng này', 'Tháng trước', 'Năm nay'];
  int _period = 0;

  final _repo = TransactionRepository.instance;

  /// Khoảng thời gian [from, to) theo chip đang chọn
  (DateTime, DateTime) _range() {
    final now = DateTime.now();
    switch (_period) {
      case 1:
        return (DateTime(now.year, now.month - 1, 1), DateTime(now.year, now.month, 1));
      case 2:
        return (DateTime(now.year, 1, 1), DateTime(now.year + 1, 1, 1));
      default:
        return (DateTime(now.year, now.month, 1), DateTime(now.year, now.month + 1, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _repo,
      builder: (context, _) {
        final (from, to) = _range();
        final byCat = _repo.expenseByCategory(from: from, to: to);
        final entries = byCat.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final total = entries.fold<int>(0, (s, e) => s + e.value);

        final colors = [
          for (final e in entries)
            TransactionCategory.find(e.key, isExpense: true).color,
        ];
        final fractions = [
          for (final e in entries) total == 0 ? 0.0 : e.value / total,
        ];

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // --- Chọn khoảng thời gian ---
            Row(
              children: [
                for (int i = 0; i < _periods.length; i++) ...[
                  _periodChip(i),
                  const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 24),

            // --- Biểu đồ tròn ---
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(220, 220),
                      painter: _DonutPainter(
                        fractions: fractions,
                        colors: colors,
                        strokeWidth: 36,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 52),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatMoney(total),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: _ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text('Tổng chi tiêu',
                              style: TextStyle(fontSize: 11, color: _muted)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Chú thích theo danh mục ---
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Chưa có chi tiêu trong khoảng thời gian này.',
                      style: TextStyle(color: _muted)),
                ),
              )
            else
              for (int i = 0; i < entries.length; i++)
                _legendRow(
                  color: colors[i],
                  name: entries[i].key,
                  amount: entries[i].value,
                  percent: (fractions[i] * 100).round(),
                ),
          ],
        );
      },
    );
  }

  Widget _periodChip(int i) {
    final selected = _period == i;
    return GestureDetector(
      onTap: () => setState(() => _period = i),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? _primary : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _periods[i],
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : _muted,
          ),
        ),
      ),
    );
  }

  Widget _legendRow({
    required Color color,
    required String name,
    required int amount,
    required int percent,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(name,
                style: const TextStyle(fontSize: 13, color: _ink)),
          ),
          Text(formatMoney(amount),
              style: const TextStyle(fontSize: 13, color: _ink)),
          SizedBox(
            width: 48,
            child: Text('$percent%',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 13, color: _muted)),
          ),
        ],
      ),
    );
  }
}

/// Vẽ biểu đồ vành khuyên (donut) bằng CustomPainter, không cần thư viện ngoài
class _DonutPainter extends CustomPainter {
  final List<double> fractions;
  final List<Color> colors;
  final double strokeWidth;

  _DonutPainter({
    required this.fractions,
    required this.colors,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(strokeWidth / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    if (fractions.isEmpty) {
      paint.color = const Color(0xFFE2E8F0);
      canvas.drawArc(arcRect, 0, 2 * math.pi, false, paint);
      return;
    }

    final gap = fractions.length > 1 ? 0.03 : 0.0;
    var start = -math.pi / 2;
    for (int i = 0; i < fractions.length; i++) {
      final sweep = 2 * math.pi * fractions[i];
      paint.color = colors[i];
      canvas.drawArc(arcRect, start + gap / 2, math.max(sweep - gap, 0.001), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter old) =>
      old.fractions != fractions || old.colors != colors;
}
