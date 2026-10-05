import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/detail_widgets.dart';
import '../widgets/notification_detail_scaffold.dart';
import '../widgets/notification_status_card.dart';
import '../widgets/vehicle_info_card.dart';
import 'queue_page.dart';

/// Halaman tujuan untuk notifikasi "Perjalanan Selesai".
class TripCompletedPage extends StatelessWidget {
  const TripCompletedPage({super.key, required this.notification});

  final AppNotification notification;

  void _openLoanDetail(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const QueuePage()));
  }

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Perjalanan Selesai',
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
            filled: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (notification.vehicle != null) ...[
            VehicleInfoCard(vehicle: notification.vehicle!),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (notification.driver != null) ...[
            _DriverSummary(driver: notification.driver!),
            const SizedBox(height: AppSpacing.xxl),
          ],
          if (notification.travel != null) ...[
            TravelDetailCard(travel: notification.travel!),
            const SizedBox(height: AppSpacing.xxl),
          ],
          SoftActionButton(
            label: 'Lihat Detail Peminjaman',
            onPressed: () => _openLoanDetail(context),
          ),
        ],
      ),
    );
  }
}

class _DriverSummary extends StatelessWidget {
  const _DriverSummary({required this.driver});

  final NotificationDriver driver;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const InfoSectionTitle(title: 'Driver'),
          const SizedBox(height: AppSpacing.xl),
          InfoRow(label: 'Nama Driver', value: driver.name),
          InfoRow(label: 'Nomor HP', value: driver.phone),
        ],
      ),
    );
  }
}
