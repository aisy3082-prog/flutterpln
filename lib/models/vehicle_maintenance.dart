/// Status satu catatan perawatan kendaraan.
enum MaintenanceStatus { selesai, berjalan, terjadwal }

extension MaintenanceStatusLabel on MaintenanceStatus {
  String get label => switch (this) {
    MaintenanceStatus.selesai => 'Selesai',
    MaintenanceStatus.berjalan => 'Berjalan',
    MaintenanceStatus.terjadwal => 'Terjadwal',
  };
}

/// Satu catatan riwayat perawatan kendaraan, ditampilkan pada bagian
/// "Informasi Perawatan" di halaman Detail Kendaraan.
class VehicleMaintenance {
  const VehicleMaintenance({
    required this.vehicleCode,
    required this.title,
    required this.date,
    required this.status,
  });

  /// Kode kendaraan pemilik catatan ini, mis. "KDN-001".
  final String vehicleCode;
  final String title;
  final String date;
  final MaintenanceStatus status;
}
