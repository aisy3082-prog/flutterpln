import '../models/driver.dart';

/// Data dummy driver. Nanti diganti dengan data dari backend.
const List<Driver> dummyDrivers = [
  Driver(id: 'DRV-001', name: 'Andi Pratama', status: DriverStatus.available),
  Driver(id: 'DRV-002', name: 'Budi Setiawan', status: DriverStatus.available),
  Driver(id: 'DRV-003', name: 'Dimas Saputra', status: DriverStatus.available),
  Driver(id: 'DRV-004', name: 'Angga Yuan', status: DriverStatus.available),
  Driver(
    id: 'DRV-005',
    name: 'Rizki Maulana',
    status: DriverStatus.busy,
  ),
];

/// Mencari driver berdasarkan id; null kalau tidak ditemukan.
Driver? driverById(String id) {
  for (final driver in dummyDrivers) {
    if (driver.id == id) {
      return driver;
    }
  }
  return null;
}
