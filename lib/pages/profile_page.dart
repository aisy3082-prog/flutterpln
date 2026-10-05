import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/user_profile.dart';
import '../state/auth_state.dart';
import '../utils/constants.dart';
import '../widgets/profile_group_row.dart';
import 'about_page.dart';
import 'help_page.dart';
import 'login_page.dart';
import 'personal_data_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  void _signOut(BuildContext context) {
    final auth = AuthStateScope.maybeOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    // Hapus session lokal lalu kembali ke Login dengan stack bersih.
    auth?.signOut();
    messenger.showSnackBar(const SnackBar(content: Text('Anda telah keluar.')));
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthStateScope.maybeOf(context);
    final UserProfile user = auth?.user ?? dummyUserProfile;

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
              const _ProfileHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.pageBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ProfileGroupCard(
                        children: [
                          // Hanya "Data Diri" yang bisa diketuk. Unit Kerja,
                          // Nomor HP, dan Email hanya keterangan sehingga tidak
                          // diberi onTap (dan chevron otomatis hilang) supaya
                          // tidak memberi kesan ada yang bisa diklik.
                          ProfileGroupRow(
                            icon: Icons.person_outline,
                            label: 'Data Diri',
                            onTap: () =>
                                _open(context, PersonalDataPage(user: user)),
                          ),
                          ProfileGroupRow(
                            icon: Icons.apartment_outlined,
                            label: 'Unit Kerja',
                            value: user.unit,
                          ),
                          ProfileGroupRow(
                            icon: Icons.phone_outlined,
                            label: 'Nomor HP',
                            value: user.phone,
                          ),
                          ProfileGroupRow(
                            icon: Icons.mail_outline,
                            label: 'Email',
                            value: user.email,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      ProfileGroupCard(
                        children: [
                          ProfileGroupRow(
                            icon: Icons.settings_outlined,
                            label: 'Pengaturan',
                            onTap: () => _open(context, const SettingsPage()),
                          ),
                          ProfileGroupRow(
                            icon: Icons.help_outline,
                            label: 'Bantuan',
                            onTap: () => _open(context, const HelpPage()),
                          ),
                          ProfileGroupRow(
                            icon: Icons.info_outline,
                            label: 'Tentang Aplikasi',
                            onTap: () => _open(context, const AboutPage()),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      _SignOutButton(onPressed: () => _signOut(context)),
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
}

/// Header biru dengan avatar, tombol kamera, dan data singkat pengguna.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final auth = AuthStateScope.maybeOf(context);
    final UserProfile user = auth?.user ?? dummyUserProfile;

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
          Center(child: _Avatar(user: user)),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Text(
                  user.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  user.status,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'NIP. ${user.nip}',
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  user.unit,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final UserProfile user;

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
                user.avatarAsset,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, _, _) => const Icon(
                  Icons.person,
                  size: 40,
                  color: AppColors.textSubtle,
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
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: onPressed,
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
}
