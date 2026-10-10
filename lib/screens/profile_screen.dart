import 'package:flutter/material.dart';

/// Màn hình Cá nhân. Không có Scaffold riêng để nhúng vào tab của Dashboard.
/// Thông tin người dùng đang để cố định; các mục menu sẽ làm ở buổi sau.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _ink = Color(0xFF0F172A);
  static const _muted = Color(0xFF64748B);
  static const _primary = Color(0xFF1967D2);
  static const _danger = Color(0xFFEF4444);

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tính năng này sẽ làm ở buổi sau')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <_MenuItem>[
      const _MenuItem(Icons.person_outline, 'Thông tin cá nhân'),
      const _MenuItem(Icons.settings_outlined, 'Cài đặt ngân sách'),
      const _MenuItem(Icons.category_outlined, 'Danh mục chi tiêu'),
      const _MenuItem(Icons.cloud_upload_outlined, 'Sao lưu dữ liệu'),
      const _MenuItem(Icons.lock_outline, 'Đổi mật khẩu'),
      const _MenuItem(Icons.logout, 'Đăng xuất', danger: true),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        // --- Thông tin người dùng ---
        Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFDCE6F7),
              child: Icon(Icons.person, size: 36, color: _primary),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nguyễn Văn A',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _ink)),
                  SizedBox(height: 4),
                  Text('nguyenvana@example.com',
                      style: TextStyle(fontSize: 12, color: _muted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(height: 1, color: Color(0xFFE2E8F0)),

        // --- Menu ---
        for (final item in items) ...[
          InkWell(
            onTap: () => _comingSoon(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Icon(item.icon,
                      size: 22, color: item.danger ? _danger : _ink),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: item.danger ? _danger : _ink,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),
        ],
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final bool danger;
  const _MenuItem(this.icon, this.label, {this.danger = false});
}
