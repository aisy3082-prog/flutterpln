import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/recent_activity_data.dart';
import '../models/recent_activity.dart';
import '../utils/app_navigation.dart';
import '../widgets/app_bottom_navigation.dart';

/// Halaman "Aktivitas Terakhir": daftar aktivitas peminjaman kendaraan
/// terbaru, dikelompokkan per tanggal. Dibuka dari link "Lihat Semua"
/// pada section "Aktivitas Terakhir" di Beranda.
class RecentActivityPage extends StatelessWidget {
  const RecentActivityPage({
    super.key,
    this.groups = dummyRecentActivityGroups,
  });

  final List<RecentActivityGroup> groups;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF20252B),
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.chevron_left, size: 24),
            tooltip: 'Kembali',
          ),
          title: const Text(
            'Aktivitas Terakhir',
            style: TextStyle(
              color: Color(0xFF20252B),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 18),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Text(
                  'Berikut adalah seluruh aktivitas terbaru terkait '
                  'peminjaman kendaraan Anda.',
                  style: TextStyle(
                    color: Color(0xFF8A949E),
                    fontSize: 9.5,
                    height: 1.45,
                  ),
                ),
              ),
              for (var i = 0; i < groups.length; i++) ...[
                _ActivityGroup(group: groups[i]),
                if (i != groups.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEDEFF1),
                  ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          selectedTab: AppTab.beranda,
        ),
      ),
    );
  }
}

/// Satu blok tanggal beserta aktivitas di bawahnya.
class _ActivityGroup extends StatelessWidget {
  const _ActivityGroup({required this.group});

  final RecentActivityGroup group;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 20, 8),
          child: Text(
            group.title,
            style: const TextStyle(
              color: Color(0xFF20252B),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final item in group.items)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: _ActivityRow(item: item),
          ),
      ],
    );
  }
}

/// Baris aktivitas: ikon mobil, nama kendaraan, waktu, dan status.
class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});

  final RecentActivity item;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (item.status) {
      RecentActivityStatus.menunggu => (
        const Color(0xFF3D9CFF),
        const Color(0xFF0B75D1),
      ),
      RecentActivityStatus.selesai => (
        const Color(0xFFB8F0C0),
        const Color(0xFF16813B),
      ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE1E5E8)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF0B75D1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.vehicleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF20252B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.dateTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF77818B),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              item.status.label,
              style: TextStyle(
                color: foreground,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
