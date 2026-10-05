import 'vehicle.dart';

/// Status ketersediaan driver.
enum DriverStatus {
  available,
  busy;

  String get label => switch (this) {
    DriverStatus.available => 'Tersedia',
    DriverStatus.busy => 'Sedang Bertugas',
  };
}

/// Data driver untuk peminjaman mobil.
///
/// Structurunya datar dan mirip bentuk respons API supaya nanti mudah
/// diganti dengan data dari backend.
class Driver {
  const Driver({
    required this.id,
    required this.name,
    required this.status,
    this.photo = 'assets/img/profil.jpg',
  });

  final String id;
  final String name;
  final DriverStatus status;
  final String photo;

  /// Driver yang sedang bertugas tidak boleh dipilih.
  bool get isSelectable => status == DriverStatus.available;

  String get initial => name.isEmpty ? 'D' : name.substring(0, 1).toUpperCase();
}

/// Driver default yang sudah ditentukan untuk sebuah kendaraan.
///
/// Setiap mobil punya driver masing-masing, jadi Admin tidak perlu memilih
/// driver dari awal. Kuncinya adalah kode kendaraan.
const Map<String, String> defaultDriverByVehicleCode = {
  'KDN-001': 'DRV-001',
  'KDN-002': 'DRV-002',
};

/// Mengembalikan driver default untuk [vehicle], atau null kalau kendaraan
/// belum punya driver default.
Driver? defaultDriverFor(
  Vehicle vehicle, {
  required List<Driver> drivers,
}) {
  final id = defaultDriverByVehicleCode[vehicle.code];
  if (id == null) {
    return null;
  }
  for (final driver in drivers) {
    if (driver.id == id) {
      return driver;
    }
  }
  return null;
}
