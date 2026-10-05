import 'package:flutter/material.dart';

import '../models/admin_dashboard.dart';
import '../models/vehicle_loan.dart';
import '../utils/constants.dart';
import 'vehicle_photo.dart';

/// Card satu peminjaman pada halaman "Daftar Peminjaman Terbaru".
///
/// Seluruh isinya (gambar, nama, kode/plat, kapasitas, peminjam, waktu, dan
/// chevron) mengikuti desain; status di pojok kanan atas memakai
/// [AdminLoanStatusBadge].
class AdminLoanCard extends StatelessWidget {
  const AdminLoanCard({super.key, required this.loan, this.onTap});

  final VehicleLoan loan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final capacity = loan.vehicle.capacity;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _VehicleImage(loan: loan),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nama kendaraan + badge status.
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            loan.vehicleName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textStrong,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        AdminLoanStatusBadge(status: loan.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Kode + plat nomor.
                    Text(
                      '${loan.vehicle.code}    ${loan.vehicle.plateNumber}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 8,
                      ),
                    ),
                    if (capacity != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Kapasitas $capacity orang',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 8,
                        ),
                      ),
                    ],
                    const SizedBox(height: 5),
                    _MetaRow(
                      icon: Icons.person_outline,
                      text: loan.borrowerName,
                    ),
                    const SizedBox(height: 3),
                    _MetaRow(
                      icon: Icons.calendar_today_outlined,
                      text: loan.dateTime,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(top: 22),
                child: Icon(
                  Icons.chevron_right,
                  size: 19,
                  color: Color(0xFF7D8791),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baris kecil: ikon biru di kiri, teks biru di kanan.
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 10, color: AppColors.primary),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.primary, fontSize: 8.5),
          ),
        ),
      ],
    );
  }
}

/// Gambar kendaraan di sisi kiri card, ukuran tetap supaya baris rapi.
class _VehicleImage extends StatelessWidget {
  const _VehicleImage({required this.loan});

  final VehicleLoan loan;

  @override
  Widget build(BuildContext context) {
    return VehiclePhoto(
      vehicle: loan.vehicle,
      width: 72,
      height: 64,
      // Foto kendaraan berlatar putih, jadi diberi latar tipis supaya
      // mobilnya tidak tenggelam di kartu putih.
      backgroundColor: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(8),
    );
  }
}

/// Badge status: biru muda untuk Menunggu, hijau muda untuk Disetujui.
class AdminLoanStatusBadge extends StatelessWidget {
  const AdminLoanStatusBadge({super.key, required this.status});

  final AdminLoanStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (status) {
      AdminLoanStatus.menunggu => (
        const Color(0xFFDDE9FB),
        const Color(0xFF0B75D1),
      ),
      AdminLoanStatus.disetujui => (
        const Color(0xFFB8F0C0),
        const Color(0xFF16813B),
      ),
      AdminLoanStatus.ditolak => (
        const Color(0xFFF9D5D5),
        const Color(0xFFD64B4B),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: foreground,
          fontSize: 7.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
