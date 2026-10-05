import '../models/recent_activity.dart';

/// Data dummy halaman "Aktivitas Terakhir", dikelompokkan per tanggal.
const List<RecentActivityGroup> dummyRecentActivityGroups = [
  RecentActivityGroup(
    title: 'Hari ini, 12 Apr 2026',
    items: [
      RecentActivity(
        vehicleName: 'Mobil - Avanza',
        dateTime: '12 Apr 2026, 08:15',
        status: RecentActivityStatus.menunggu,
      ),
    ],
  ),
  RecentActivityGroup(
    title: 'Kemarin, 11 Apr 2026',
    items: [
      RecentActivity(
        vehicleName: 'Mobil - Toyota Innova',
        dateTime: '11 Apr 2026, 09:20',
        status: RecentActivityStatus.selesai,
      ),
    ],
  ),
  RecentActivityGroup(
    title: 'Apr 2026',
    items: [
      RecentActivity(
        vehicleName: 'Mobil - Toyota Innova',
        dateTime: '01 Apr 2026, 09:20',
        status: RecentActivityStatus.selesai,
      ),
      RecentActivity(
        vehicleName: 'Mobil - Toyota Innova',
        dateTime: '28 Mar 2026, 09:20',
        status: RecentActivityStatus.selesai,
      ),
      RecentActivity(
        vehicleName: 'Mobil - Toyota Innova',
        dateTime: '25 Mar 2026, 09:20',
        status: RecentActivityStatus.selesai,
      ),
      RecentActivity(
        vehicleName: 'Mobil - Toyota Innova',
        dateTime: '20 Mar 2026, 09:20',
        status: RecentActivityStatus.selesai,
      ),
    ],
  ),
];
