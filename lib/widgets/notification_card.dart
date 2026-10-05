import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../utils/constants.dart';

/// Resolve warna & ikon berdasarkan jenis notifikasi.
({Color color, IconData icon}) notificationStyle(NotificationType type) =>
    switch (type) {
      NotificationType.perjalananSelesai => (
        color: AppColors.success,
        icon: Icons.check_rounded,
      ),
      NotificationType.pengajuanDisetujui => (
        color: AppColors.success,
        icon: Icons.check_rounded,
      ),
      NotificationType.driverDitugaskan => (
        color: AppColors.primary,
        icon: Icons.directions_car_rounded,
      ),
    };

/// Card satu notifikasi di daftar.
class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.notification, this.onTap});

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = notificationStyle(notification.type);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: style.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(style.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.description,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.time,
                      style: const TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: style.color,
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: AppSpacing.md),
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: Color(0xFF7D8791),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
