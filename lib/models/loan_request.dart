enum LoanRequestStatus { menungguPersetujuan, disetujui, ditolak }

extension LoanRequestStatusLabel on LoanRequestStatus {
  String get label => switch (this) {
    LoanRequestStatus.menungguPersetujuan => 'Menunggu Persetujuan',
    LoanRequestStatus.disetujui => 'Disetujui',
    LoanRequestStatus.ditolak => 'Ditolak',
  };
}

/// Data pengajuan kendaraan yang sedang diproses.
///
/// Model ini sengaja tidak bergantung pada halaman supaya saat dummy data
/// diganti API, bentuk datanya tetap sama.
class LoanRequest {
  const LoanRequest({
    required this.number,
    required this.vehicleName,
    required this.vehicleCode,
    required this.plateNumber,
    required this.purpose,
    required this.destination,
    required this.submittedAt,
    required this.borrowDate,
    required this.returnDate,
    required this.status,
    this.approver,
  });

  final String number;
  final String vehicleName;
  final String vehicleCode;
  final String plateNumber;
  final String purpose;
  final String destination;
  final String submittedAt;
  final String borrowDate;
  final String returnDate;
  final LoanRequestStatus status;
  final String? approver;
}
