import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/detail_widgets.dart';
import '../widgets/driver_card.dart';
import '../widgets/notification_detail_scaffold.dart';
import '../widgets/notification_status_card.dart';
import 'queue_page.dart';

/// Halaman tujuan untuk notifikasi "Driver telah ditugaskan".
class DriverConfirmPage extends StatelessWidget {
  const DriverConfirmPage({super.key, required this.notification});

  final AppNotification notification;

  void _openLoanDetail(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const QueuePage()));
  }

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Konfirmasi Driver',
      selectedTab: AppTab.notifikasi,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NotificationStatusCard(
            icon: Icons.directions_car_rounded,
            accentColor: AppColors.primary,
            title: notification.title,
            description: '',
            meta: notification.dateRange ?? notification.time,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (notification.driver != null)
                  DriverCard(driver: notification.driver!),
                if (notification.driver != null &&
                    notification.vehicle != null) ...[
                  const SizedBox(height: AppSpacing.xl),
                  const InfoDivider(),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (notification.vehicle != null)
                  DriverVehicleRow(vehicle: notification.vehicle!),
                const SizedBox(height: AppSpacing.xxl),
                const InfoDivider(),
                const SizedBox(height: AppSpacing.xl),
                SoftActionButton(
                  label: 'Lihat Detail Peminjaman',
                  onPressed: () => _openLoanDetail(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
