import 'package:flutter/material.dart';

import '../models/admin_notification.dart';
import '../utils/constants.dart';

/// Card satu notifikasi di daftar Notifikasi Admin.
///
/// Ikatan sudah dibaca ditandai dengan latar yang sangat tipis sehingga
/// notifikasi baru terlihat lebih menonjol tanpa perlu indikator tambahan.
class AdminNotificationCard extends StatelessWidget {
  const AdminNotificationCard({super.key, required this.notification, this.onTap});

  final AdminNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final type = notification.type;
    final isUnread = !notification.isRead;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            // Latar notifikasi yang sudah dibaca diberi warna sangat tipis
            // supaya bedanya halus tapi tetap terbaca.
            color: isUnread ? Colors.white : const Color(0xFFFAFBFC),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(
              color: isUnread ? AppColors.border : AppColors.borderSoft,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: type.color,
                  shape: BoxShape.circle,
                ),
                child: Icon(type.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.description,
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      notification.dateTimeLabel,
                      style: TextStyle(
                        color: AppColors.textSubtle,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              // Titik kecil menandai notifikasi yang belum dibaca.
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: type.color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
