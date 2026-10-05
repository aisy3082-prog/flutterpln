import 'package:flutter/material.dart';

import '../state/admin_notification_state.dart';
import 'app_nav_bar.dart';

/// Bottom Navigation khusus Admin (4 menu).
///
/// Hanya pembungkus [AppNavBar] — sama seperti navbar user — supaya tidak ada
/// dua implementasi navbar dengan metrik yang bisa berbeda. Yang membedakan
/// hanya [AppNavStyle.elevated] (kartu melayang) sesuai desain Admin.
class AdminBottomNavigation extends StatelessWidget {
  const AdminBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.unreadNotificationCount = false,
  });

  /// Tab aktif, memakai indeks tetap milik Admin.
  final int selectedIndex;

  /// Dipanggil dengan indeks tab yang ditekan.
  final ValueChanged<int> onSelected;

  /// Kalau true, menu Notifikasi menampilkan badge berisi jumlah notifikasi
  /// belum dibaca. Nilainya diambil dari [AdminNotificationStateScope] yang
  /// ada di halaman, sehingga badge ikut berubah saat notifikasi dibaca.
  final bool unreadNotificationCount;

  /// Key item menu Notifikasi, dipakai untuk memasang badge.
  static const String notifikasiKey = 'admin_bottom_nav_Notifikasi';

  /// Urutan tetap: 0 = Beranda, 1 = Kendaraan, 2 = Notifikasi, 3 = Profil.
  ///
  /// Menu "Peminjaman" tidak ada di sini karena isinya sama dengan
  /// "Peminjaman Terbaru" di Beranda yang sudah punya link "Lihat Semua".
  static const List<AppNavItem> items = [
    AppNavItem(
      key: 'admin_bottom_nav_Beranda',
      label: 'Beranda',
      icon: Icons.home_outlined,
    ),
    AppNavItem(
      key: 'admin_bottom_nav_Kendaraan',
      label: 'Kendaraan',
      icon: Icons.directions_car_outlined,
    ),
    AppNavItem(
      key: notifikasiKey,
      label: 'Notifikasi',
      icon: Icons.notifications_none,
    ),
    AppNavItem(
      key: 'admin_bottom_nav_Profil',
      label: 'Profil',
      icon: Icons.person_outline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unread = unreadNotificationCount
        ? (AdminNotificationStateScope.maybeOf(context)?.unreadCount ?? 0)
        : 0;

    return AppNavBar(
      selectedIndex: selectedIndex,
      onSelected: onSelected,
      style: AppNavStyle.elevated,
      // Badge hanya menempel pada menu Notifikasi. Dicocokkan lewat key
      // supaya tetap benar kalau urutan menu berubah.
      items: [
        for (final item in items)
          AppNavItem(
            key: item.key,
            label: item.label,
            icon: item.icon,
            badge: item.key == notifikasiKey ? unread : 0,
          ),
      ],
    );
  }
}
