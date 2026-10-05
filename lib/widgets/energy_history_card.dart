import 'package:flutter/material.dart';

import '../models/history_models.dart';
import '../utils/constants.dart';

/// Card riwayat energi. Komponen dan layout sama untuk BBM maupun listrik;
/// hanya label, satuan, dan baris informasi yang menyesuaikan.
class EnergyHistoryCard extends StatelessWidget {
  const EnergyHistoryCard({super.key, required this.record});

  final EnergyHistory record;

  @override
  Widget build(BuildContext context) {
    final isElectric = record.type == HistoryEnergyType.listrik;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isElectric ? 'Informasi Pengisian Listrik' : 'Informasi Pengisian',
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          EnergyRow(
            icon: Icons.calendar_today_outlined,
            label: isElectric ? 'Tanggal Pengisian' : 'Tanggal',
            value: record.date,
          ),
          EnergyRow(
            icon: Icons.local_gas_station_outlined,
            label: isElectric ? 'Jenis Kendaraan' : 'Jenis BBM',
            value: isElectric ? 'Kendaraan Listrik' : record.name,
          ),
          EnergyRow(
            icon: Icons.bolt_outlined,
            label: isElectric ? 'Jumlah Energi' : 'Jumlah Liter',
            value: '${record.amount} ${record.unit}',
          ),
          EnergyRow(
            icon: Icons.payments_outlined,
            label: isElectric ? 'Biaya Pengisian' : 'Harga per Liter',
            value: record.pricePerUnit,
          ),
          EnergyRow(
            icon: Icons.receipt_long_outlined,
            label: 'Total Biaya',
            value: record.totalCost,
          ),
          EnergyRow(
            icon: Icons.route_outlined,
            label: 'Jarak / KM',
            value: record.distanceKm,
          ),
          if (isElectric)
            EnergyRow(
              icon: Icons.place_outlined,
              label: 'Lokasi Pengisian',
              value: record.location,
            ),
        ],
      ),
    );
  }
}

class EnergyRow extends StatelessWidget {
  const EnergyRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSubtle, fontSize: 8),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card bukti pengisian.
class FuelProofCard extends StatelessWidget {
  const FuelProofCard({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined, color: AppColors.textStrong),
          const SizedBox(width: AppSpacing.lg),
          const Expanded(
            child: Text(
              'Bukti Pengisian',
              style: TextStyle(
                color: AppColors.textStrong,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
            ),
            child: const Text('Lihat foto', style: TextStyle(fontSize: 8)),
          ),
        ],
      ),
    );
  }
}
