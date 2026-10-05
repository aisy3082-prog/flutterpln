import '../models/admin_notification.dart';

/// Data dummy notifikasi Admin.
///
/// Tiga notifikasi pertama dibuat belum dibaca supaya badge bottom nav
/// menampilkan angka 3, sesuai desain.
List<AdminNotification> buildDummyAdminNotifications() => [
  AdminNotification(
    id: 'NTF-2026-0001',
    type: AdminNotificationType.peminjamanBaru,
    title: 'Peminjaman Baru',
    description:
        'Andi Pratama mengajukan peminjaman mobil Toyota Avanza.',
    date: '12 Sep 2026',
    time: '07:45',
    detailTitle: 'Detail Peminjaman',
    showLoanButton: true,
    detailFields: [
      const AdminNotificationField('Nama Peminjam', 'Andi Pratama'),
      const AdminNotificationField('Kendaraan', 'Toyota Avanza'),
      const AdminNotificationField('Tanggal Pengajuan', '12 Sep 2026'),
      const AdminNotificationField('Waktu Pengajuan', '07:45'),
      const AdminNotificationField(
        'Status',
        'Menunggu Persetujuan',
        isStatus: true,
      ),
    ],
  ),
  AdminNotification(
    id: 'NTF-2026-0002',
    type: AdminNotificationType.permintaanSelesai,
    title: 'Permintaan Selesai',
    description:
        'Budi Setiawan telah mengembalikan kendaraan Toyota Avanza.',
    date: '12 Sep 2026',
    time: '16:30',
    detailTitle: 'Detail Pengembalian',
    showLoanButton: true,
    detailFields: [
      const AdminNotificationField('Nama Pengembali', 'Budi Setiawan'),
      const AdminNotificationField('Kendaraan', 'Toyota Avanza'),
      const AdminNotificationField('Waktu Pengembalian', '12 Sep 2026, 16:30'),
      const AdminNotificationField('Status', 'Selesai', isStatus: true),
    ],
  ),
  AdminNotification(
    id: 'NTF-2026-0003',
    type: AdminNotificationType.pengisianBbm,
    title: 'Pengisian BBM',
    description:
        'Driver mengisi BBM untuk kendaraan Honda Beat.',
    date: '12 Sep 2026',
    time: '15:20',
    detailTitle: 'Detail Pengisian BBM',
    detailFields: [
      const AdminNotificationField('Nama Driver', 'Andi Pratama'),
      const AdminNotificationField('Kendaraan', 'Honda Beat'),
      const AdminNotificationField('Jenis BBM', 'Pertamax'),
      const AdminNotificationField('Volume', '20 Liter'),
      const AdminNotificationField('Waktu Pengisian', '12 Sep 2026, 15:20'),
    ],
  ),
  AdminNotification(
    id: 'NTF-2026-0004',
    type: AdminNotificationType.perawatanKendaraan,
    title: 'Perawatan Kendaraan',
    description: 'Toyota Innova memerlukan pengecekan rutin.',
    date: '11 Sep 2026',
    time: '10:00',
    isRead: true,
    detailTitle: 'Detail Perawatan',
    detailFields: [
      const AdminNotificationField('Kendaraan', 'Toyota Innova'),
      const AdminNotificationField('Jenis Perawatan', 'Pengecekan rutin'),
      const AdminNotificationField('Tanggal Perawatan', '11 Sep 2026'),
      const AdminNotificationField('Waktu', '10:00'),
    ],
  ),
  AdminNotification(
    id: 'NTF-2026-0005',
    type: AdminNotificationType.peminjamanDitolak,
    title: 'Peminjaman Ditolak',
    description: 'Permintaan peminjaman Honda Beat ditolak oleh admin.',
    date: '10 Sep 2026',
    time: '09:15',
    isRead: true,
    detailTitle: 'Detail Peminjaman',
    detailFields: [
      const AdminNotificationField('Nama Peminjam', 'Siti Aminah'),
      const AdminNotificationField('Kendaraan', 'Honda Beat'),
      const AdminNotificationField('Tanggal Pengajuan', '10 Sep 2026'),
      const AdminNotificationField(
        'Status',
        'Ditolak',
        isStatus: true,
      ),
    ],
  ),
];
