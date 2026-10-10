import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_category.dart';
import '../models/transaction_model.dart';
import '../utils/formatters.dart';
import 'edit_transaction_screen.dart';

/// Danh sách giao dịch (dạng thẻ, không có Scaffold riêng để nhúng vào
/// Dashboard). Tự cập nhật khi repository thay đổi.
/// - [limit] != null => chỉ hiện [limit] giao dịch mới nhất
class TransactionListScreen extends StatelessWidget {
  final int? limit;

  const TransactionListScreen({super.key, this.limit});

  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    final repo = TransactionRepository.instance;

    return ListenableBuilder(
      listenable: repo,
      builder: (context, _) {
        final all = repo.all;
        final list = limit == null ? all : all.take(limit!).toList();

        if (list.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'Chưa có giao dịch nào.\nBấm nút + để thêm.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted),
              ),
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
                _TransactionTile(transaction: list[i]),
                if (i != list.length - 1)
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final cat = TransactionCategory.find(t.category, isExpense: t.isExpense);
    final amountColor =
        t.isExpense ? const Color(0xFFEF4444) : const Color(0xFF16A34A);
    final title = t.note.trim().isEmpty ? t.category : t.note;

    return InkWell(
      // bấm vào => mở màn hình Sửa giao dịch
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EditTransactionScreen(transaction: t),
        ),
      ),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: cat.color,
              child: Icon(cat.icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: TransactionListScreen._ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.category,
                    style: const TextStyle(
                      fontSize: 10,
                      color: TransactionListScreen._muted,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                formatDate(t.date),
                style: const TextStyle(
                  fontSize: 10,
                  color: TransactionListScreen._muted,
                ),
              ),
            ),
            Text(
              '${t.isExpense ? '-' : '+'}${formatMoney(t.amount)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
