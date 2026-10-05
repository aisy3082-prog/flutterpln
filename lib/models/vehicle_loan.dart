import '../models/vehicle.dart';
import 'admin_dashboard.dart';

/// Satu catatan peminjaman kendaraan untuk halaman Admin.
///
/// Data kendaraan (nama, kode, plat, kapasitas, gambar) diambil dari
/// [Vehicle] yang sudah dipakai user, sehingga tidak ada duplikasi.
/// Bagian yang khas Admin — peminjam, jadwal, tujuan, driver, dan status —
/// disimpan di sini.
///
/// Structurunya sengaja dibuat datar dan mirip bentuk respons API supaya
/// nanti tinggal ganti sumber datanya tanpa mengubah halaman.
class VehicleLoan {
  const VehicleLoan({
    required this.id,
    required this.vehicle,
    required this.borrowerName,
    required this.borrowerPhone,
    required this.startDate,
    required this.startTime,
    required this.returnDate,
    required this.returnTime,
    required this.destination,
    required this.status,
    this.driverId,
  });

  final String id;
  final Vehicle vehicle;
  final String borrowerName;
  final String borrowerPhone;

  /// Tanggal dan waktu pinjam, mis. "14 Sep 2026" dan "08:00".
  final String startDate;
  final String startTime;

  /// Tanggal dan waktu rencana kembali.
  final String returnDate;
  final String returnTime;

  final String destination;
  final AdminLoanStatus status;

  /// Id driver yang sudah ditetapkan; null berarti belum ada driver.
  final String? driverId;

  String get vehicleName => vehicle.name;
  VehicleType get vehicleType => vehicle.type;
  bool get isMobil => vehicleType == VehicleType.mobil;

  /// Tanggal + waktu pinjam, dipakai card di daftar.
  String get dateTime => '$startDate, $startTime';

  /// Tanggal + waktu kembali, dipakai pada detail.
  String get returnDateTime => '$returnDate, $returnTime';

  /// Rentang jadwal untuk bagian "Jadwal".
  String get scheduleLabel => '$startDate, $startTime - $returnTime';

  bool get isWaiting => status == AdminLoanStatus.menunggu;

  /// Mobil wajib punya driver sebelum bisa disetujui.
  bool get hasDriver => driverId != null && driverId!.isNotEmpty;

  /// Teks yang dipakai search bar: nama/kode/plat kendaraan dan peminjam.
  String get searchableText =>
      '${vehicle.name} ${vehicle.code} ${vehicle.plateNumber} '
      '$borrowerName'.toLowerCase();

  /// True kalau kata kunci cocok dengan nama, kode/plat, atau peminjam.
  bool matches(String query) {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return true;
    }
    return searchableText.contains(keyword);
  }

  VehicleLoan copyWith({
    AdminLoanStatus? status,
    String? driverId,
  }) => VehicleLoan(
    id: id,
    vehicle: vehicle,
    borrowerName: borrowerName,
    borrowerPhone: borrowerPhone,
    startDate: startDate,
    startTime: startTime,
    returnDate: returnDate,
    returnTime: returnTime,
    destination: destination,
    status: status ?? this.status,
    driverId: driverId ?? this.driverId,
  );
}
