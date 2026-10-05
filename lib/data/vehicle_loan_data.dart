import '../models/admin_dashboard.dart';
import '../models/vehicle.dart';
import '../models/vehicle_loan.dart';

/// Kendaraan yang dipakai pada daftar peminjaman Admin.
///
/// `Vehicle` sudah punya field yang dibutuhkan (nama, kode, plat, kapasitas,
/// gambar), jadi di sini hanya tinggal merangkainya.
const Vehicle _innova = Vehicle(
  name: 'Toyota Innova',
  code: 'KDN-001',
  plateNumber: 'AB 123 XX',
  type: VehicleType.mobil,
  status: VehicleStatus.tersedia,
  imageAsset: 'assets/img/mobil.png',
  capacity: 7,
);

const Vehicle _lifan = Vehicle(
  name: 'Lifan',
  code: 'KDM-001',
  plateNumber: 'AB 123 XX',
  type: VehicleType.motor,
  status: VehicleStatus.tersedia,
  imageAsset: 'assets/img/motor.jpeg',
  capacity: 2,
);

/// Data dummy daftar peminjaman terbaru untuk Admin.
///
/// Satu daftar ini dipakai bersama oleh Beranda Admin, Daftar Peminjaman
/// Terbaru, halaman Detail, dan Konfirmasi Driver — jadi id dan datanya
/// selalu sama di semua halaman.
const List<VehicleLoan> dummyVehicleLoans = [
  VehicleLoan(
    id: 'PLN-2026-0001',
    vehicle: _innova,
    borrowerName: 'Budi Santoso',
    borrowerPhone: '085xxxxxxxx',
    startDate: '14 Sep 2026',
    startTime: '08:00',
    returnDate: '14 Sep 2026',
    returnTime: '16:00',
    destination: 'Batik, kuliner magelang',
    status: AdminLoanStatus.menunggu,
  ),
  VehicleLoan(
    id: 'PLN-2026-0002',
    vehicle: _lifan,
    borrowerName: 'Siti Aminah',
    borrowerPhone: '085xxxxxxxx',
    startDate: '21 Sep 2026',
    startTime: '08:00',
    returnDate: '21 Sep 2026',
    returnTime: '13:00',
    destination: 'PLN Borobudur',
    status: AdminLoanStatus.menunggu,
  ),
  VehicleLoan(
    id: 'PLN-2026-0003',
    vehicle: _innova,
    borrowerName: 'Prabowo',
    borrowerPhone: '085xxxxxxxx',
    startDate: '12 Sep 2026',
    startTime: '08:00',
    returnDate: '12 Sep 2026',
    returnTime: '16:00',
    destination: 'Batik, kuliner magelang',
    status: AdminLoanStatus.disetujui,
    driverId: 'DRV-001',
  ),
  VehicleLoan(
    id: 'PLN-2026-0004',
    vehicle: _lifan,
    borrowerName: 'Ucup Markucup',
    borrowerPhone: '085xxxxxxxx',
    startDate: '13 Sep 2026',
    startTime: '08:00',
    returnDate: '13 Sep 2026',
    returnTime: '16:00',
    destination: 'PLN Borobudur',
    status: AdminLoanStatus.disetujui,
  ),
];
