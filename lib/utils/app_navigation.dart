import 'package:flutter/material.dart';

import '../pages/app_shell_page.dart';

/// Menu utama aplikasi, sesuai desain Bottom Navigation: 4 menu.
///
/// Urutan enum ini adalah index tetap yang dipakai bersama oleh shell dan
/// Bottom Navigation:
/// 0 = Beranda, 1 = Kendaraan, 2 = Notifikasi, 3 = Profil.
enum AppTab { beranda, kendaraan, notifikasi, profil }

extension AppTabLabel on AppTab {
  String get label => switch (this) {
    AppTab.beranda => 'Beranda',
    AppTab.kendaraan => 'Kendaraan',
    AppTab.notifikasi => 'Notifikasi',
    AppTab.profil => 'Profil',
  };

  IconData get icon => switch (this) {
    AppTab.beranda => Icons.home_outlined,
    AppTab.kendaraan => Icons.directions_car_outlined,
    AppTab.notifikasi => Icons.notifications_none,
    AppTab.profil => Icons.person_outline,
  };
}

/// Membuka aplikasi di shell (Beranda) sebagai root, membuang onboarding
/// dan login dari stack.
void openAppAsRoot(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const AppShellPage()),
    (route) => false,
  );
}

/// Navigasi Bottom Navigation yang global.
///
/// Kalau halaman ini berada di dalam shell, perpindahan tab hanya mengganti
/// `selectedIndex` tanpa menyentuh `Navigator` — jadi mustahil gagal atau
/// membuka halaman yang salah. Dari halaman turunan, stack dibersihkan dan
/// shell dibuka langsung pada tab tujuan.
void navigateToAppTab(BuildContext context, {required AppTab target}) {
  final shell = AppShellScope.maybeOf(context);
  if (shell != null) {
    shell.selectTab(target);
    return;
  }

  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => AppShellPage(initialTab: target)),
    (route) => false,
  );
}
