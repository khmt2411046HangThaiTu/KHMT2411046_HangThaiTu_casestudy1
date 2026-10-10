/// 8000000 -> "8.000.000 đ" (số âm có dấu "-")
String formatMoney(int v) {
  final s = v.abs().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => '.',
      );
  return '${v < 0 ? '-' : ''}$s đ';
}

/// DateTime -> "dd/mm/yyyy"
String formatDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
