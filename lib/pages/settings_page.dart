import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../state/auth_state.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/notification_detail_scaffold.dart';
import '../widgets/profile_menu_row.dart';
import 'about_page.dart';
import 'personal_data_page.dart';

/// Halaman Pengaturan. Semua nilai masih state lokal, tanpa database.
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    this.showBottomNav = true,
    this.profileTarget,
  });

  /// Diisi false saat dibuka dari area Admin supaya navbar user tidak muncul.
  final bool showBottomNav;

  /// Halaman yang dibuka dari baris "Edit Profil".
  ///
  /// Kalau null, memakai [PersonalDataPage] milik user. Area Admin mengoper
  /// halaman Data Diri Admin-nya sendiri supaya tidak salahrole.
  final Widget? profileTarget;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _loanNotification = true;
  bool _approvalNotification = true;
  bool _emailNotification = false;
  bool _darkMode = false;
  String _language = 'Indonesia';

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Pengaturan',
      selectedTab: AppTab.profil,
      showBottomNav: widget.showBottomNav,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GroupTitle('Akun'),
          const SizedBox(height: AppSpacing.md),
          ProfileMenuCard(
            children: [
              ProfileMenuRow(
                icon: Icons.person_outline,
                label: 'Edit Profil',
                onTap: () => _openProfile(context),
              ),
              ProfileMenuRow(
                icon: Icons.lock_outline,
                label: 'Ubah Password',
                onTap: () => _showPasswordDialog(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _GroupTitle('Notifikasi'),
          const SizedBox(height: AppSpacing.md),
          ProfileMenuCard(
            children: [
              _ToggleRow(
                icon: Icons.directions_car_outlined,
                label: 'Notifikasi Peminjaman',
                value: _loanNotification,
                onChanged: (value) => setState(() => _loanNotification = value),
              ),
              _ToggleRow(
                icon: Icons.assignment_outlined,
                label: 'Notifikasi Persetujuan',
                value: _approvalNotification,
                onChanged: (value) =>
                    setState(() => _approvalNotification = value),
              ),
              _ToggleRow(
                icon: Icons.mail_outline,
                label: 'Notifikasi via Email',
                value: _emailNotification,
                onChanged: (value) =>
                    setState(() => _emailNotification = value),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          const _GroupTitle('Aplikasi'),
          const SizedBox(height: AppSpacing.md),
          ProfileMenuCard(
            children: [
              _ToggleRow(
                icon: Icons.dark_mode_outlined,
                label: 'Tema Gelap',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
              ProfileMenuRow(
                icon: Icons.language_outlined,
                label: 'Bahasa',
                value: _language,
                onTap: () => _pickLanguage(context),
              ),
              ProfileMenuRow(
                icon: Icons.info_outline,
                label: 'Tentang Aplikasi',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        AboutPage(showBottomNav: widget.showBottomNav),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openProfile(BuildContext context) {
    // Kalau pemanggil memberi halaman sendiri (area Admin), pakai itu.
    final target = widget.profileTarget;
    if (target != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => target),
      );
      return;
    }

    final auth = AuthStateScope.maybeOf(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PersonalDataPage(user: auth?.user ?? dummyUserProfile),
      ),
    );
  }

  void _pickLanguage(BuildContext context) {
    const options = ['Indonesia', 'English'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final option in options)
                ListTile(
                  title: Text(option, style: const TextStyle(fontSize: 11)),
                  trailing: option == _language
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                          size: 18,
                        )
                      : null,
                  onTap: () {
                    setState(() => _language = option);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showPasswordDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Ubah Password',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Fitur ubah password membutuhkan backend dan belum tersedia '
            'pada versi ini.',
            style: TextStyle(fontSize: 10, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Mengerti'),
            ),
          ],
        );
      },
    );
  }
}

class _GroupTitle extends StatelessWidget {
  const _GroupTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textStrong,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFCFD8E0),
          ),
        ],
      ),
    );
  }
}
