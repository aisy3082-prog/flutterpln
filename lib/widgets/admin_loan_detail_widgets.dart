import 'package:flutter/material.dart';

import '../models/admin_dashboard.dart';
import '../models/vehicle.dart';
import '../models/vehicle_loan.dart';
import '../utils/constants.dart';

/// Card kendaraan untuk halaman detail: gambar, nama, kode, plat, dan badge
/// jenis kendaraan. Dipakai oleh halaman Detail maupun Konfirmasi Driver
/// supaya keduanya tidak terlihat berbeda.
class AdminLoanVehicleCard extends StatelessWidget {
  const AdminLoanVehicleCard({
    super.key,
    required this.loan,
    this.onTap,
    this.showChevron = true,
  });

  final VehicleLoan loan;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final isMobil = loan.isMobil;
    final tint = isMobil ? AppColors.primary : const Color(0xFF35A744);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSoft),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 48,
                alignment: Alignment.center,
                child: Image.asset(
                  loan.vehicle.imageAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, _, _) => const Icon(
                    Icons.directions_car,
                    size: 24,
                    color: Color(0xFFB4BCC4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loan.vehicleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textStrong,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${loan.vehicle.code}    ${loan.vehicle.plateNumber}',
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tint,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          loan.vehicleType.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showChevron)
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF7D8791),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Judul section putih dengan garis pemisah, mis. "Informasi Peminjaman".
class AdminDetailSectionTitle extends StatelessWidget {
  const AdminDetailSectionTitle(this.title, {super.key});

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

/// Satu baris "ikon + label" dengan nilai di bawahnya, seperti pada desain
/// "Informasi Peminjaman".
class AdminInfoItem extends StatelessWidget {
  const AdminInfoItem({
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 13, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSubtle,
                  fontSize: 8,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 8.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Blok "Informasi Peminjaman" lengkap: nama, no HP, tanggal pinjam,
/// tanggal kembali, dan tujuan.
class AdminLoanInfoSection extends StatelessWidget {
  const AdminLoanInfoSection({super.key, required this.loan});

  final VehicleLoan loan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminDetailSectionTitle('Informasi Peminjaman'),
        const SizedBox(height: 10),
        AdminInfoItem(
          icon: Icons.person_outline,
          label: 'Nama',
          value: loan.borrowerName,
        ),
        const SizedBox(height: 9),
        AdminInfoItem(
          icon: Icons.phone_outlined,
          label: 'No. HP',
          value: loan.borrowerPhone,
        ),
        const SizedBox(height: 9),
        AdminInfoItem(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal Pinjam',
          value: loan.dateTime,
        ),
        const SizedBox(height: 9),
        AdminInfoItem(
          icon: Icons.calendar_today_outlined,
          label: 'Tanggal Kembali',
          value: loan.returnDateTime,
        ),
        const SizedBox(height: 9),
        AdminInfoItem(
          icon: Icons.place_outlined,
          label: 'Tujuan',
          value: loan.destination,
        ),
      ],
    );
  }
}

/// Kotak status: judul "Status" + badge sesuai status peminjaman.
class AdminLoanStatusSection extends StatelessWidget {
  const AdminLoanStatusSection({super.key, required this.loan});

  final VehicleLoan loan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AdminDetailSectionTitle('Status'),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: AdminLoanDetailStatus(status: loan.status),
        ),
      ],
    );
  }
}

/// Badge status untuk halaman detail (lebih besar dari badge di card daftar).
class AdminLoanDetailStatus extends StatelessWidget {
  const AdminLoanDetailStatus({super.key, required this.status});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        status.detailLabel,
        style: TextStyle(
          color: foreground,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Kartu putih yang membungkus satu blok konten.
class AdminInfoCard extends StatelessWidget {
  const AdminInfoCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: child,
    );
  }
}
