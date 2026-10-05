/// Status aktivitas pada halaman "Aktivitas Terakhir".
enum RecentActivityStatus { menunggu, selesai }

extension RecentActivityStatusLabel on RecentActivityStatus {
  String get label => switch (this) {
    RecentActivityStatus.menunggu => 'Menunggu',
    RecentActivityStatus.selesai => 'Selesai',
  };
}

/// Satu baris aktivitas peminjaman kendaraan.
class RecentActivity {
  const RecentActivity({
    required this.vehicleName,
    required this.dateTime,
    required this.status,
  });

  final String vehicleName;
  final String dateTime;
  final RecentActivityStatus status;
}

/// Aktivitas yang dikelompokkan per tanggal, mis. "Hari ini, 12 Apr 2026".
class RecentActivityGroup {
  const RecentActivityGroup({required this.title, required this.items});

  final String title;
  final List<RecentActivity> items;
}
