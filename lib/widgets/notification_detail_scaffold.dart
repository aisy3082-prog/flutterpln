import 'package:flutter/material.dart';

import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/app_bottom_navigation.dart';

/// Scaffold bersama untuk halaman detail notifikasi (Detail Notifikasi,
/// Konfirmasi Driver, Perjalanan Selesai) dan halaman turunan Profil
/// (Data Diri, Pengaturan, Bantuan, Tentang Aplikasi).
///
/// Menyediakan header dengan tombol back, konten yang bisa di-scroll, dan
/// Bottom Navigation tunggal milik aplikasi.
class NotificationDetailScaffold extends StatelessWidget {
  const NotificationDetailScaffold({
    super.key,
    required this.title,
    required this.child,
    this.selectedTab = AppTab.notifikasi,
    this.showBottomNav = true,
  });

  final String title;
  final Widget child;

  /// Tab yang ditandai aktif pada Bottom Navigation.
  final AppTab selectedTab;

  /// Kalau false, navbar user disembunyikan.
  ///
  /// Dipakai ketika halaman turunan Profil ini dibuka dari area Admin, supaya
  /// navbar milik user tidak ikut muncul di area Admin. Halaman detail Admin
  /// lainnya memang sengaja tanpa navbar.
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Kembali',
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textStrong,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.pageBottom,
          ),
          child: child,
        ),
      ),
      bottomNavigationBar: showBottomNav
          ? AppBottomNavigation(selectedTab: selectedTab)
          : null,
    );
  }
}
