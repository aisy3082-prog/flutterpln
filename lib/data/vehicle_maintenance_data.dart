import '../models/vehicle_maintenance.dart';

/// Catatan perawatan dummy untuk halaman Detail Kendaraan.
///
/// Nanti diganti dengan data dari backend.
const List<VehicleMaintenance> dummyVehicleMaintenance = [
  VehicleMaintenance(
    vehicleCode: 'KDN-001',
    title: 'Service rutin',
    date: '10 Des 2025',
    status: MaintenanceStatus.selesai,
  ),
  VehicleMaintenance(
    vehicleCode: 'KDN-001',
    title: 'Ganti oli',
    date: '12 Sep 2025',
    status: MaintenanceStatus.selesai,
  ),
  VehicleMaintenance(
    vehicleCode: 'KDN-001',
    title: 'Cek rem & ban',
    date: '20 Jun 2025',
    status: MaintenanceStatus.selesai,
  ),
  VehicleMaintenance(
    vehicleCode: 'KDN-002',
    title: 'Ganti oli',
    date: '05 Nov 2025',
    status: MaintenanceStatus.selesai,
  ),
  VehicleMaintenance(
    vehicleCode: 'KDN-003',
    title: 'Pemasangan aki baru',
    date: '18 Jan 2026',
    status: MaintenanceStatus.berjalan,
  ),
  VehicleMaintenance(
    vehicleCode: 'KDM-001',
    title: 'Servis/setir',
    date: '02 Feb 2026',
    status: MaintenanceStatus.selesai,
  ),
  VehicleMaintenance(
    vehicleCode: 'KDM-002',
    title: 'Ganti ban',
    date: '14 Jan 2026',
    status: MaintenanceStatus.berjalan,
  ),
];

/// Catatan perawatan milik satu kendaraan.
List<VehicleMaintenance> maintenanceOf(String vehicleCode) =>
    dummyVehicleMaintenance
        .where((item) => item.vehicleCode == vehicleCode)
        .toList();
