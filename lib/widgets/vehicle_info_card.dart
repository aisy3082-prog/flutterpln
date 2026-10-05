import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../utils/constants.dart';
import 'detail_widgets.dart';

/// Card "Informasi Kendaraan" berisi jenis kendaraan, plat, dan merek/tipe.
class VehicleInfoCard extends StatelessWidget {
  const VehicleInfoCard({super.key, required this.vehicle});

  final NotificationVehicle vehicle;

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
          const InfoSectionTitle(title: 'Informasi Kendaraan'),
          const SizedBox(height: AppSpacing.xl),
          InfoRow(label: 'Jenis Kendaraan', value: vehicle.type),
          InfoRow(label: 'Plat Nomor', value: vehicle.plateNumber),
          InfoRow(label: 'Merek/Tipe', value: vehicle.brand, showColon: true),
        ],
      ),
    );
  }
}

/// Card ringkasan info untuk halaman Detail Notifikasi (Pengajuan disetujui).
///
/// Sesuai desain, tombol "Lihat Detail Peminjaman" berada di dalam card.
class ApprovalInfoCard extends StatelessWidget {
  const ApprovalInfoCard({
    super.key,
    required this.vehicleType,
    required this.destination,
    required this.dateRange,
    this.onPressed,
  });

  final String vehicleType;
  final String destination;
  final String dateRange;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InfoRow(label: 'Jenis Kendaraan', value: vehicleType),
          const SizedBox(height: AppSpacing.md),
          InfoRow(label: 'Tujuan', value: destination),
          const SizedBox(height: AppSpacing.md),
          InfoRow(label: 'Tanggal', value: dateRange),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryActionButton(
            label: 'Lihat Detail Peminjaman',
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

/// Card "Rincian Perjalanan".
class TravelDetailCard extends StatelessWidget {
  const TravelDetailCard({super.key, required this.travel});

  final TravelDetail travel;

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
          const InfoSectionTitle(title: 'Rincian Perjalanan'),
          const SizedBox(height: AppSpacing.xl),
          InfoRow(label: 'Tanggal Berangkat', value: travel.departAt),
          InfoRow(label: 'Tanggal Selesai', value: travel.arriveAt),
          InfoRow(label: 'Tujuan', value: travel.destination),
          InfoRow(label: 'Jarak Tempuh', value: travel.distance),
        ],
      ),
    );
  }
}
