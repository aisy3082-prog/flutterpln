import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import 'vehicle_photo.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({super.key, required this.vehicle, required this.onTap});

  final Vehicle vehicle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Hanya kendaraan "Tersedia" yang bisa dipinjam, jadi hanya card itu
    // yang menampilkan panah penanda aksi dan bisa diketuk.
    final canBorrow = vehicle.status == VehicleStatus.tersedia;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE1E5E8)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VehiclePhoto(
                vehicle: vehicle,
                width: 68,
                height: 58,
                // Foto kendaraan berlatar putih, jadi diberi latar tipis
                // supaya mobilnya tidak tenggelam di kartu putih.
                backgroundColor: const Color(0xFFF1F5F9),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF20252B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vehicle.code,
                      style: const TextStyle(
                        color: Color(0xFF65707A),
                        fontSize: 8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      vehicle.plateNumber,
                      style: const TextStyle(
                        color: Color(0xFF65707A),
                        fontSize: 8,
                      ),
                    ),
                    if (vehicle.capacity != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Kapasitas ${vehicle.capacity} orang',
                        style: const TextStyle(
                          color: Color(0xFF65707A),
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  VehicleStatusBadge(status: vehicle.status),
                  // Panah hanya untuk kendaraan yang statusnya "Tersedia".
                  if (canBorrow) ...[
                    const SizedBox(height: 17),
                    const Icon(
                      Icons.chevron_right,
                      size: 19,
                      color: Color(0xFF7D8791),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VehicleStatusBadge extends StatelessWidget {
  const VehicleStatusBadge({super.key, required this.status});

  final VehicleStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = switch (status) {
      VehicleStatus.tersedia => (
        background: const Color(0xFFDDF5E2),
        foreground: const Color(0xFF1E9B3B),
      ),
      VehicleStatus.digunakan => (
        background: const Color(0xFFFDE8B0),
        foreground: const Color(0xFFB27A00),
      ),
      VehicleStatus.perawatan => (
        background: const Color(0xFFF9D5D5),
        foreground: const Color(0xFFD64B4B),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
