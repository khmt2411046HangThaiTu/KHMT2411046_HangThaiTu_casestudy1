import 'package:flutter/material.dart';
import 'add_edit_transaction_screen.dart';

void main() {
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Tắt chữ DEBUG ở góc màn hình
      home: const HomeScreen(), // Tách riêng để context có Navigator hợp lệ
    );
  }
}

// Widget riêng cho màn hình chào (Splash/Home), nằm BÊN TRONG MaterialApp
// => context của widget này mới "nhìn thấy" được Navigator.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,   // Nền màn hình màu trắng tinh khiết
        body: SafeArea(                  // Bảo vệ không bị che bởi tai thỏ, pin
          child: Padding(
            padding: const EdgeInsets.all(24), // Cách đều 4 mép màn hình 24px
            child: Column(
              children: [
                // 1. Khối nội dung chính ở giữa (dùng Expanded để đẩy nút xuống đáy)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // Gom vào giữa
                    children: [
                      // Logo ví tiền gốc
                      Image.asset(
                        'assets/images/logo.png',
                        width: 140, // Kích thước to rõ, nổi bật
                      ),
                      const SizedBox(height: 32), // Khoảng cách giữa ảnh và chữ

                      // Tiêu đề ứng dụng
                      const Text(
                        'Expense Manager',
                        style: TextStyle(
                          fontSize: 32,                 // Chữ to bản 32px
                          fontWeight: FontWeight.w800,  // In đậm đầm mắt
                          letterSpacing: -0.6,          // Khoảng cách chữ hiện đại
                          color: Color(0xFF0F172A),     // Màu xanh đen Slate-900
                        ),
                      ),
                      const SizedBox(height: 14), // Khoảng cách giữa 2 dòng chữ

                      // Dòng mô tả 2 dòng căn giữa
                      const Text(
                        'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.2,
                          color: Color(0xFF64748B),     // Màu xám nhã nhặn
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Nút bấm ở đáy màn hình
                SizedBox(
                  width: double.infinity, // Kéo rộng hết chiều ngang màn hình
                  child: ElevatedButton(
                    onPressed: () {
                      // Mở màn hình "Thêm giao dịch"
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const AddEditTransactionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1967D2), // Xanh dương đặc
                      foregroundColor: Colors.white,              // Chữ màu trắng
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),  // Bo góc chữ nhật nhẹ
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14), // Chiều cao vừa vặn
                      elevation: 2,
                    ),
                    child: const Text(
                      'Bắt đầu',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
