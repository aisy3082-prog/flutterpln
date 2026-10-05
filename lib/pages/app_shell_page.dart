import 'package:flutter/material.dart';

import '../utils/app_navigation.dart';
import '../widgets/app_bottom_navigation.dart';
import 'home_page.dart';
import 'notification_page.dart';
import 'profile_page.dart';
import 'vehicle_list_page.dart';

/// Satu-satunya tempat yang menyimpan tab aktif.
///
/// Keempat halaman utama hidup di dalam [IndexedStack] dan_bottom
/// navigation_ menjadi satu-satunya Bottom Navigation di aplikasi ini.
///Karena tidak ada `Navigator` yang dipakai untuk berpindah tab, tidak
/// mungkin ada tombol yang tidak merespons atau salah membuka halaman.
class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key, this.initialTab = AppTab.beranda});

  final AppTab initialTab;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  /// Index tetap: 0 = Beranda, 1 = Kendaraan, 2 = Notifikasi, 3 = Profil.
  static final List<Widget> _pages = const [
    HomePage(),
    VehicleListPage(),
    NotificationPage(),
    ProfilePage(),
  ];

  late int _selectedIndex = AppTab.values.indexOf(widget.initialTab);

  void _onTabSelected(AppTab tab) {
    final next = AppTab.values.indexOf(tab);
    if (next == _selectedIndex) {
      return;
    }
    setState(() {
      _selectedIndex = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      currentTab: AppTab.values[_selectedIndex],
      selectTab: _onTabSelected,
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: AppBottomNavigation(
          selectedTab: AppTab.values[_selectedIndex],
          onSelected: _onTabSelected,
        ),
      ),
    );
  }
}

/// Membuat tab shell yang sedang aktif bisa diakses dari halaman mana pun
/// tanpa harus berpindah route.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.currentTab,
    required this.selectTab,
    required super.child,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> selectTab;

  /// Shell yang sedang aktif, atau null jika halaman ini bukan bagian shell.
  static AppShellScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope oldWidget) =>
      oldWidget.currentTab != currentTab;
}
