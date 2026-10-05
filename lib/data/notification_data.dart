import '../models/app_notification.dart';

/// Data dummy notifikasi. Nanti tinggal ganti pemanggilnya dengan API
/// tanpa mengubah widget maupun halaman.
final List<AppNotification> dummyNotifications = [
  AppNotification(
    id: 'notif-001',
    type: NotificationType.perjalananSelesai,
    title: 'Perjalanan Selesai',
    description:
        'Perjalanan dengan tujuan Yogyakarta telah diselesaikan dengan sukses.',
    time: '11.30 WIB',
    isRead: true,
    vehicle: NotificationVehicle(
      type: 'Mobil Dinas',
      plateNumber: 'B 123 KZ',
      brand: 'Toyota Innova',
    ),
    driver: NotificationDriver(
      name: 'Budi Santoso',
      phone: '0883 7755 7778',
      imageAsset: 'assets/img/profil.jpg',
    ),
    travel: TravelDetail(
      departAt: '12 Apr 2026 - 10.00 WIB',
      arriveAt: '12 Apr 2026 - 16.30 WIB',
      destination: 'Kantor Cabang',
      distance: '186 km',
    ),
  ),
  AppNotification(
    id: 'notif-002',
    type: NotificationType.pengajuanDisetujui,
    title: 'Pengajuan disetujui',
    description:
        'Pengajuan mobil dinas untuk kegiatan di Yogyakarta telah disetujui oleh admin.',
    time: '09.15 WIB',
    isRead: false,
    vehicle: NotificationVehicle(
      type: 'Mobil Dinas',
      plateNumber: 'B 123 KZ',
      brand: 'Toyota Innova',
    ),
    destination: 'Kegiatan di Yogyakarta',
    dateRange: '14 April 2026 - 15 April 2026',
  ),
  AppNotification(
    id: 'notif-003',
    type: NotificationType.driverDitugaskan,
    title: 'Driver telah ditugaskan',
    description:
        'Driver untuk peminjaman mobilmu sudah ditentukan. Silakan cek detail peminjaman.',
    time: '08.42 WIB',
    isRead: false,
    vehicle: NotificationVehicle(
      type: 'Mobil Dinas',
      plateNumber: 'B 1234 XX',
      brand: 'Toyota Innova',
    ),
    driver: NotificationDriver(
      name: 'Budi Santoso',
      phone: '0883 7755 7778',
      imageAsset: 'assets/img/profil.jpg',
    ),
    dateRange: '08.42 WIB, 12 April 2025',
  ),
];

/// Salinan data dummy agar state lokal tidak mengubah sumber global.
List<AppNotification> buildDummyNotifications() =>
    dummyNotifications.map((n) => n.copyWith()).toList();
