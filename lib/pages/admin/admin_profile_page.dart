import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/admin_profile.dart';
import '../../state/admin_auth_state.dart';
import '../../utils/constants.dart';
import '../../widgets/profile_group_row.dart';
import '../about_page.dart';
import '../help_page.dart';
import '../settings_page.dart';
import 'admin_login_page.dart';
import 'admin_personal_data_page.dart';

/// Profil Admin: header biru, avatar, data diri, menu, dan tombol Keluar.
///
/// Data masih dummy dan tombol Keluar baru menampilkan konfirmasi singkat,
/// belum melakukan logout sungguhan karena belum ada autentikasi Admin.
class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key, this.profile = dummyAdminProfile});

  final AdminProfile profile;

  @override
  Widget build(BuildContext context) {
    // Kalau ada session login, pakai data dari session; kalau tidak
    // (misalnya saat pratinjau) pakai dummy.
    final admin =
        AdminAuthStateScope.maybeOf(context)?.profile ?? profile;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF2E86DE),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _AdminProfileHeader(profile: admin),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                    AppSpacing.xxl,
                    AppSpacing.pageBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileGroupCard(
                        children: [
                          // Hanya "Data Diri" yang bisa diketuk. Akses,
                          // Nomor HP, dan Email hanya keterangan, sehingga
                          // tidak diberi onTap (dan chevron otomatis hilang)
                          // supaya tidak memberi kesan ada yang bisa diklik.
                          ProfileGroupRow(
                            icon: Icons.person_outline,
                            label: 'Data Diri',
                            value: admin.name,
                            onTap: () => _openPersonalData(context, admin),
                          ),
                          ProfileGroupRow(
                            icon: Icons.badge_outlined,
                            label: 'Akses',
                            value: admin.role,
                          ),
                          ProfileGroupRow(
                            icon: Icons.phone_outlined,
                            label: 'Nomor HP',
                            value: admin.phone,
                          ),
                          ProfileGroupRow(
                            icon: Icons.mail_outline,
                            label: 'Email',
                            value: admin.email,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ProfileGroupCard(
                        children: [
                          ProfileGroupRow(
                            icon: Icons.settings_outlined,
                            label: 'Pengaturan',
                            onTap: () => _open(
                              context,
                              SettingsPage(
                                // Halaman yang sama dengan user, tanpa navbar
                                // user dan memakai Data Diri milik Admin.
                                showBottomNav: false,
                                profileTarget: AdminPersonalDataPage(
                                  profile: admin,
                                ),
                              ),
                            ),
                          ),
                          ProfileGroupRow(
                            icon: Icons.help_outline,
                            label: 'Bantuan',
                            onTap: () => _open(
                              context,
                              const HelpPage(showBottomNav: false),
                            ),
                          ),
                          ProfileGroupRow(
                            icon: Icons.info_outline,
                            label: 'Tentang Aplikasi',
                            onTap: () => _open(
                              context,
                              const AboutPage(showBottomNav: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      const _SignOutButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Membuka halaman Data Diri Admin yang sudah ada.
  void _openPersonalData(BuildContext context, AdminProfile admin) {
    _open(context, AdminPersonalDataPage(profile: admin));
  }

  /// Membuka halaman turunan Profil. Halaman turunan Admin mengikuti pola
  /// halaman detail Admin lain, yaitu tanpa navbar.
  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }
}

/// Header biru gradien dengan judul "Profil", avatar, dan role Admin.
class _AdminProfileHeader extends StatelessWidget {
  const _AdminProfileHeader({required this.profile});

  final AdminProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E86DE), Color(0xFFA8D4F7)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(child: _AdminAvatar(profile: profile)),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  profile.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.role,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminAvatar extends StatelessWidget {
  const _AdminAvatar({required this.profile});

  final AdminProfile profile;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              color: AppColors.primarySoft,
            ),
            child: ClipOval(
              child: Image.asset(
                profile.avatarAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, _, _) => const Icon(
                  Icons.person,
                  size: 40,
                  color: Color(0xFF8A949E),
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.photo_camera_outlined,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: () => _confirmSignOut(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE60000),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: const Text(
          'Keluar',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    // Hapus session Admin lalu kembali ke Login Admin dengan stack bersih.
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    AdminAuthStateScope.maybeOf(context)?.signOut();
    messenger.showSnackBar(
      const SnackBar(content: Text('Anda telah keluar dari akun Admin.')),
    );
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const AdminLoginPage()),
      (route) => false,
    );
  }
}
