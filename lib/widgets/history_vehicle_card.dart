import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../utils/constants.dart';
import 'vehicle_photo.dart';

/// Card kendaraan ringkas untuk halaman riwayat.
class HistoryVehicleCard extends StatelessWidget {
  const HistoryVehicleCard({super.key, required this.vehicle, this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              VehiclePhoto(
                vehicle: vehicle,
                width: 70,
                height: 48,
                // Foto kendaraan berlatar putih, jadi diberi latar tipis
                // supaya mobilnya tidak tenggelam di kartu putih.
                backgroundColor: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${vehicle.code}   ${vehicle.plateNumber}',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF7D8791),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
