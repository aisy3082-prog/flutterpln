import '../models/loan_request.dart';

/// Dummy pengajuan aktif (dipakai card "Pengajuan Aktif" di Beranda).
const List<LoanRequest> dummySubmissions = [
  LoanRequest(
    number: 'PNG-2026-0042',
    vehicleName: 'Mobil - Avanza',
    vehicleCode: 'KDN-001',
    plateNumber: 'AB 123 XX',
    purpose: 'Pemeliharaan Jaringan',
    destination: 'UP3 Magelang',
    submittedAt: '12 Sep 2026, 08:15',
    borrowDate: '12 Sep 2026',
    returnDate: '12 Sep 2026',
    status: LoanRequestStatus.menungguPersetujuan,
  ),
];

/// Dummy pengajuan yang menunggu persetujuan (card "Menunggu Persetujuan").
const List<LoanRequest> dummyPendingApprovals = [
  LoanRequest(
    number: 'PNG-2026-0041',
    vehicleName: 'Toyota Innova',
    vehicleCode: 'KDN-002',
    plateNumber: 'AB 456 YY',
    purpose: 'Rapat Koordinasi',
    destination: 'Kantor PLN',
    submittedAt: '11 Sep 2026, 09:20',
    borrowDate: '13 Sep 2026',
    returnDate: '13 Sep 2026',
    status: LoanRequestStatus.menungguPersetujuan,
  ),
];
