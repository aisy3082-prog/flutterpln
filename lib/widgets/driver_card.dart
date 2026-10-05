import 'package:flutter/material.dart';

import '../models/app_notification.dart';
import '../utils/constants.dart';

/// Card driver: avatar, nama, dan status ketersediaan.
class DriverCard extends StatelessWidget {
  const DriverCard({super.key, required this.driver});

  final NotificationDriver driver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            driver.imageAsset ?? 'assets/img/profil.jpg',
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, _, _) => Container(
              width: 40,
              height: 40,
              color: AppColors.neutralIcon,
              child: const Icon(
                Icons.person_outline,
                color: AppColors.textSubtle,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                driver.name,
                style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.circle, size: 9, color: AppColors.success),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    driver.status,
                    style: const TextStyle(
                      color: AppColors.successText,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Baris kendaraan pada card driver: ikon netral, merek, dan plat.
class DriverVehicleRow extends StatelessWidget {
  const DriverVehicleRow({super.key, required this.vehicle});

  final NotificationVehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.neutralIcon,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_car_rounded,
            color: AppColors.textStrong,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicle.brand,
                style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                vehicle.plateNumber,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
