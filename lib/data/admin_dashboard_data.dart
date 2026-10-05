import 'package:flutter/material.dart';

import '../models/admin_dashboard.dart';
import '../models/vehicle.dart';

/// Data dummy dashboard Beranda Admin.
///
/// Seluruh nilai masih hardcoded dan akan diganti dengan data backend
/// setelah endpoint-nya siap.
const List<AdminStat> dummyAdminStats = [
  AdminStat(
    icon: Icons.directions_car,
    title: 'Peminjaman Mobil',
    value: 5,
    caption: 'Menunggu persetujuan',
    tint: AdminStatTint.biru,
  ),
  AdminStat(
    icon: Icons.two_wheeler,
    title: 'Peminjaman Motor',
    value: 3,
    caption: 'Menunggu persetujuan',
    tint: AdminStatTint.hijau,
  ),
  AdminStat(
    icon: Icons.person_pin_circle,
    title: 'Menunggu Driver',
    value: 2,
    caption: '(Mobil)',
    tint: AdminStatTint.merah,
  ),
  AdminStat(
    icon: Icons.check_circle,
    title: 'Disetujui Hari Ini',
    value: 6,
    caption: 'Pinjaman',
    tint: AdminStatTint.kuning,
  ),
];

/// Daftar peminjaman terbaru sesuai desain.
const List<AdminLoan> dummyAdminLoans = [
  AdminLoan(
    vehicleName: 'Mobil - Avanza',
    vehicleType: VehicleType.mobil,
    dateTime: '12 Sep 2026, 08:15',
    status: AdminLoanStatus.menunggu,
  ),
  AdminLoan(
    vehicleName: 'Motor - Honda Beat',
    vehicleType: VehicleType.motor,
    dateTime: '12 Sep 2026, 10:15',
    status: AdminLoanStatus.menunggu,
  ),
  AdminLoan(
    vehicleName: 'Mobil - Toyota Inova',
    vehicleType: VehicleType.mobil,
    dateTime: '11 Sep 2026, 09:20',
    status: AdminLoanStatus.disetujui,
  ),
];
