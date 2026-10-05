enum NotificationType {
  perjalananSelesai,
  pengajuanDisetujui,
  driverDitugaskan,
}

extension NotificationTypeLabel on NotificationType {
  String get label => switch (this) {
    NotificationType.perjalananSelesai => 'Perjalanan Selesai',
    NotificationType.pengajuanDisetujui => 'Pengajuan disetujui',
    NotificationType.driverDitugaskan => 'Driver telah ditugaskan',
  };
}

/// Informasi kendaraan yang ditampilkan pada halaman detail notifikasi.
class NotificationVehicle {
  const NotificationVehicle({
    required this.type,
    required this.plateNumber,
    required this.brand,
  });

  /// Contoh: "Mobil Dinas".
  final String type;
  final String plateNumber;

  /// Contoh: "Toyota Innova".
  final String brand;
}

/// Informasi driver yang ditugaskan.
class NotificationDriver {
  const NotificationDriver({
    required this.name,
    required this.phone,
    this.status = 'Tersedia',
    this.imageAsset,
  });

  final String name;
  final String phone;
  final String status;
  final String? imageAsset;
}

/// Rincian perjalanan untuk notifikasi Perjalanan Selesai.
class TravelDetail {
  const TravelDetail({
    required this.departAt,
    required this.arriveAt,
    required this.destination,
    required this.distance,
  });

  final String departAt;
  final String arriveAt;
  final String destination;
  final String distance;
}

/// Model notifikasi aplikasi.
///
/// Field wajibnya (id, type, title, description, time, isRead) mengikuti
/// kontrak API. Sisa field opsional hanya dipakai oleh halaman detail
/// sehingga model ini tetap aman kalau backend hanya mengirim field dasar.
///
/// `isRead` sengaja `bool` (bukan `final`) supaya bisa diubah secara lokal
/// saat notifikasi dibuka; saat backend siap, nilai ini datang dari server.
class AppNotification {
  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.time,
    this.isRead = false,
    this.vehicle,
    this.driver,
    this.travel,
    this.destination,
    this.dateRange,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String description;
  final String time;
  bool isRead;

  /// Data tambahan untuk halaman detail.
  final NotificationVehicle? vehicle;
  final NotificationDriver? driver;
  final TravelDetail? travel;
  final String? destination;
  final String? dateRange;

  AppNotification copyWith({bool? isRead}) => AppNotification(
    id: id,
    type: type,
    title: title,
    description: description,
    time: time,
    isRead: isRead ?? this.isRead,
    vehicle: vehicle,
    driver: driver,
    travel: travel,
    destination: destination,
    dateRange: dateRange,
  );
}
