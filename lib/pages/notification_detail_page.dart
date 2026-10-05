import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/notification_detail_scaffold.dart';
import '../widgets/notification_status_card.dart';
import '../widgets/vehicle_info_card.dart';
import 'queue_page.dart';

/// Halaman tujuan untuk notifikasi "Pengajuan disetujui".
class NotificationDetailPage extends StatelessWidget {
  const NotificationDetailPage({super.key, required this.notification});

  final AppNotification notification;

  void _openLoanDetail(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const QueuePage()));
  }

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Detail Notifikasi',
      selectedTab: AppTab.notifikasi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NotificationStatusCard(
            icon: Icons.check_rounded,
            accentColor: AppColors.success,
            title: notification.title,
            description: notification.description,
            meta: notification.time,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            notification.description,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ApprovalInfoCard(
            vehicleType: notification.vehicle?.type ?? 'Mobil Dinas',
            destination: notification.destination ?? '-',
            dateRange: notification.dateRange ?? '-',
            onPressed: () => _openLoanDetail(context),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const Text(
            'Detail Notifikasi',
            style: TextStyle(
              color: AppColors.textStrong,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Menampilkan informasi lengkap dari notifikasi yang dipilih.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
