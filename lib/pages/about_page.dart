import 'package:flutter/material.dart';

import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/notification_detail_scaffold.dart';

const String aboutAppVersion = '1.0.0';
const String aboutAppDeveloper = 'PLN UP3 Magelang';

/// Halaman Tentang Aplikasi: logo, nama, versi, dan deskripsi singkat.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key, this.showBottomNav = true});

  /// Diisi false saat dibuka dari area Admin supaya navbar user tidak muncul.
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Tentang Aplikasi',
      selectedTab: AppTab.profil,
      showBottomNav: showBottomNav,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Image.asset(
              'assets/img/logo.png',
              width: 72,
              height: 72,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, _, _) => Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Text(
            'PLN UP3 Magelang',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textStrong,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Aplikasi Peminjaman Kendaraan Dinas',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                'Versi $aboutAppVersion',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: const Text(
              'Aplikasi untuk membantu proses pengajuan, pemantauan, dan '
              'pengelolaan peminjaman kendaraan dinas di PLN UP3 Magelang.',
              style: TextStyle(
                color: AppColors.textStrong,
                fontSize: 10,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderSoft),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _AboutRow(label: 'Pengembang', value: aboutAppDeveloper),
                const SizedBox(height: AppSpacing.lg),
                const _AboutRow(label: 'Versi', value: aboutAppVersion),
                const SizedBox(height: AppSpacing.lg),
                const _AboutRow(label: 'Lisensi', value: 'Internal PLN'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSubtle, fontSize: 9),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            ':',
            style: TextStyle(color: AppColors.textSubtle, fontSize: 9),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
