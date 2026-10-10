import 'package:flutter/material.dart';
import '../repositories/transaction_repository.dart';
import '../models/transaction_model.dart';
import 'add_transaction_screen.dart';

/// Màn hình Sửa giao dịch: dùng lại form chung, điền sẵn dữ liệu cũ
class EditTransactionScreen extends StatelessWidget {
  final TransactionModel transaction;

  const EditTransactionScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return TransactionFormScreen(
      title: 'Sửa giao dịch',
      initial: transaction,
      onSave: TransactionRepository.instance.update,
    );
  }
}
