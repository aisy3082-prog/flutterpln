import 'package:flutter/material.dart';

import '../../widgets/admin_bottom_navigation.dart';
import 'admin_home_page.dart';
import 'admin_notification_page.dart';
import 'admin_profile_page.dart';
import 'admin_vehicle_page.dart';

/// Satu-satunya tempat yang menyimpan tab aktif untuk area Admin.
///
/// Kelima halaman utama hidup di dalam satu [IndexedStack] dengan Bottom
/// Navigation sebagai satu-satunya navbar, sama seperti pola yang dipakai
/// shell user. Karena tidak ada `Navigator` untuk berpindah tab, setiap
/// tombol pasti membuka tab yang ditujunya.
class AdminShellPage extends StatefulWidget {
  const AdminShellPage({super.key, this.initialIndex = 0});

  static const int indexBeranda = 0;
  static const int indexKendaraan = 1;
  static const int indexNotifikasi = 2;
  static const int indexProfil = 3;

  /// Tab yang dibuka pertama kali, memakai indeks tetap di atas.
  final int initialIndex;

  @override
  State<AdminShellPage> createState() => _AdminShellPageState();
}

class _AdminShellPageState extends State<AdminShellPage> {
  /// Index tetap: 0 = Beranda, 1 = Kendaraan, 2 = Notifikasi, 3 = Profil.
  ///
  /// Daftar Peminjaman tidak menjadi tab karena isinya sama dengan
  /// "Peminjaman Terbaru" di Beranda; halaman itu tetap bisa dibuka lewat
  /// link "Lihat Semua" maupun card statistik, dan navbar-nya sendiri
  /// disediakan shell.
  static final List<Widget> _pages = [
    const AdminHomePage(),
    const AdminVehiclePage(embedded: true),
    const AdminNotificationPage(embedded: true),
    const AdminProfilePage(),
  ];

  late int _selectedIndex = widget.initialIndex;

  void _onTabSelected(int index) {
    if (index == _selectedIndex) {
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminShellScope(
      currentIndex: _selectedIndex,
      selectTab: _onTabSelected,
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: AdminBottomNavigation(
          selectedIndex: _selectedIndex,
          onSelected: _onTabSelected,
          // Badge jumlah notifikasi belum dibaca ikut tampil di navbar ini,
          // sehingga ikut berkurang begitu notifikasi detail dibuka.
          unreadNotificationCount: true,
        ),
      ),
    );
  }
}

/// Membuat tab shell Admin aktif bisa diakses dari halaman mana pun tanpa
/// harus berpindah route.
class AdminShellScope extends InheritedWidget {
  const AdminShellScope({
    super.key,
    required this.currentIndex,
    required this.selectTab,
    required super.child,
  });

  final int currentIndex;
  final ValueChanged<int> selectTab;

  static AdminShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AdminShellScope>();

  @override
  bool updateShouldNotify(AdminShellScope oldWidget) =>
      oldWidget.currentIndex != currentIndex;
}

/// Membuka area Admin sebagai root, membuang halaman sebelumnya dari stack.
///
/// Dipakai oleh entry point Admin (untuk tahap ini dipanggil dari
/// [openAdminPreview]). Nanti saat autentikasi Admin tersedia, pemanggilnya
/// diganti ke alur login Admin tanpa mengubah isi shell.
void openAdminAsRoot(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const AdminShellPage()),
    (route) => false,
  );
}

/// Membuka shell Admin langsung pada tab tertentu. Dipakai oleh halaman
/// turunan Admin agar tombol navbar tidak pernah membuka halaman yang salah.
void openAdminTab(BuildContext context, {required int index}) {
  final shell = AdminShellScope.maybeOf(context);
  if (shell != null) {
    shell.selectTab(index);
    return;
  }
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(
      builder: (_) => AdminShellPage(initialIndex: index),
    ),
    (route) => false,
  );
}

/// Entry point sementara untuk melihat area Admin selama belum ada login
/// Admin. NANTI DIGANTI oleh alur autentikasi Admin.
void openAdminPreview(BuildContext context) => openAdminAsRoot(context);
