import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../utils/constants.dart';
import '../widgets/vehicle_card.dart' show VehicleStatusBadge;
import '../widgets/vehicle_photo.dart';
import 'admin_header_actions.dart';

/// AppBar halaman Admin yang memakai bagian kanan header standar
/// (notifikasi + profil yang bisa ditekan).
///
/// Alias dari [AdminPageAppBar] supaya pemanggil di area kendaraan tidak
/// perlu mengimpot widget header yang sama berulang kali.
class AdminVehicleAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AdminVehicleAppBar({super.key, required this.title});

  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(44);

  @override
  Widget build(BuildContext context) {
    return AdminPageAppBar(title: title);
  }
}

/// Card ringkasan kendaraan: foto, nama, kode + plat, badge status, dan
/// chevron. Dipakai oleh halaman Detail Kendaraan dan Edit Kendaraan
/// supaya keduanya menampilkan ringkasan yang sama.
class AdminVehicleSummaryCard extends StatelessWidget {
  const AdminVehicleSummaryCard({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    final isMobil = vehicle.type == VehicleType.mobil;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          VehiclePhoto(
            vehicle: vehicle,
            width: 56,
            height: 46,
            fallbackIcon: isMobil
                ? Icons.directions_car
                : Icons.two_wheeler,
            // Foto kendaraan berlatar putih, jadi diberi latar tipis supaya
            // mobilnya tidak tenggelam di kartu putih.
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
                    color: AppColors.textStrong,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${vehicle.code}    ${vehicle.plateNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 8,
                  ),
                ),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: VehicleStatusBadge(status: vehicle.status),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 19,
            color: Color(0xFF7D8791),
          ),
        ],
      ),
    );
  }
}

/// Judul section dengan garis pemisah, mis. "Informasi Perawatan".
class AdminVehicleSectionTitle extends StatelessWidget {
  const AdminVehicleSectionTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textStrong,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Divider(height: 1, thickness: 1, color: Color(0xFFEDEFF1)),
      ],
    );
  }
}
