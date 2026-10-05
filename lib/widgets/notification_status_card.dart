import 'package:flutter/material.dart';

import '../utils/constants.dart';

/// Card status di bagian atas halaman detail notifikasi.
///
/// `filled` dipakai untuk Perjalanan Selesai (latar hijau muda), sedangkan
/// `outlined` dipakai untuk Pengajuan disetujui dan Driver ditugaskan
/// (latar putih dengan border).
class NotificationStatusCard extends StatelessWidget {
  const NotificationStatusCard({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.description,
    this.meta,
    this.filled = false,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String description;
  final String? meta;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: filled ? AppColors.successSoft : Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(
          color: filled ? AppColors.successBorder : AppColors.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (description.isNotEmpty)
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 8,
                      height: 1.35,
                    ),
                  ),
                if (meta != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    meta!,
                    style: const TextStyle(
                      color: AppColors.textSubtle,
                      fontSize: 8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
