import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vehicle_data.dart';
import '../models/vehicle.dart';
import '../state/loan_state.dart';
import 'loan_application_page.dart';
import 'queue_page.dart';
import 'trip_detail_page.dart';
import 'history_page.dart';
import 'recent_activity_page.dart';
import 'approval_status_page.dart';
import 'submission_status_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final loanState = LoanStateScope.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final horizontalPadding = compact ? 12.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  8,
                  horizontalPadding,
                  18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HomeHeader(compact: compact),
                    const SizedBox(height: 14),
                    _VehicleBanner(compact: compact),
                    const SizedBox(height: 16),
                    const _SectionTitle('Ringkasan Kendaraan'),
                    const SizedBox(height: 8),
                    _VehicleSummary(compact: compact),
                    const SizedBox(height: 16),
                    const _SectionTitle('Aktivitas Saya'),
                    const SizedBox(height: 8),
                    _MyActivity(
                      compact: compact,
                      stats: _HomeStats(
                        activeSubmissions: loanState.activeSubmissions,
                        pendingApprovals: loanState.pendingApprovals,
                        hasActiveTrip: loanState.hasActiveTrip,
                        historyCount: loanState.historyCount,
                      ),
                      onSubmissionTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const SubmissionStatusPage(),
                          ),
                        );
                      },
                      onApprovalTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const ApprovalStatusPage(),
                          ),
                        );
                      },
                      onActiveTripTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TripDetailPage(
                              vehicle: loanState.currentVehicle,
                            ),
                          ),
                        );
                      },
                      onHistoryTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _LatestActivityHeader(
                      onViewAll: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RecentActivityPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _ActivityRow(
                      title: 'Mobil - Avanza',
                      date: '12 Sep 2026, 08:15',
                      status: 'Menunggu',
                      statusColor: const Color(0xFF3D9CFF),
                      statusTextColor: const Color(0xFF0B75D1),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const QueuePage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _ActivityRow(
                      title: 'Mobil - Toyota Innova',
                      date: '11 Sep 2026, 09:20',
                      status: 'Selesai',
                      statusColor: const Color(0xFFB8F0C0),
                      statusTextColor: const Color(0xFF16813B),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => TripDetailPage(
                              vehicle: loanState.currentVehicle,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compact ? 34 : 38,
          height: compact ? 34 : 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE4F0FF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF0B75D1)),
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/img/profil.jpg',
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(width: 9),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, Andi Pratama',
                style: TextStyle(
                  color: Color(0xFF20252B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Pegawai - UPJS Magdalena',
                style: TextStyle(color: Color(0xFF77818B), fontSize: 8),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_none,
            size: 21,
            color: Color(0xFF3E464E),
          ),
          tooltip: 'Notifikasi',
        ),
      ],
    );
  }
}

class _VehicleBanner extends StatelessWidget {
  const _VehicleBanner({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: compact ? 92 : 102),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B75D1), Color(0xFF075EAD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Butuh kendaraan dinas?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajukan peminjaman sekarang\ndengan mudah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 8,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 26,
                  child: FilledButton(
                    onPressed: () {
                      LoanStateScope.of(context).beginNewRequest();
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const LoanApplicationPage(),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0B75D1),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Ajukan Peminjaman'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: compact ? 100 : 130,
            height: compact ? 60 : 76,
            child: Image.asset(
              'assets/img/mobil.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF20252B),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _VehicleSummary extends StatelessWidget {
  const _VehicleSummary({required this.compact});

  final bool compact;

  int _countFor(VehicleStatus status) {
    return dummyVehicles.where((vehicle) => vehicle.status == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.directions_car,
            iconColor: const Color(0xFF35A744),
            number: '${_countFor(VehicleStatus.tersedia)}',
            label: 'Tersedia',
            compact: compact,
          ),
        ),
        SizedBox(width: compact ? 5 : 8),
        Expanded(
          child: _SummaryCard(
            icon: Icons.directions_car,
            iconColor: const Color(0xFFF28B36),
            number: '${_countFor(VehicleStatus.digunakan)}',
            label: 'Digunakan',
            compact: compact,
          ),
        ),
        SizedBox(width: compact ? 5 : 8),
        Expanded(
          child: _SummaryCard(
            icon: Icons.directions_car,
            iconColor: const Color(0xFFE53935),
            number: '${_countFor(VehicleStatus.perawatan)}',
            label: 'Perawatan',
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.number,
    required this.label,
    required this.compact,
  });

  final IconData icon;
  final Color iconColor;
  final String number;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: compact ? 78 : 84,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD8DDE2)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: compact ? 20 : 23),
          const SizedBox(height: 3),
          Text(
            number,
            style: TextStyle(
              color: iconColor,
              fontSize: compact ? 17 : 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF30363D), fontSize: 8),
          ),
        ],
      ),
    );
  }
}

/// Angka pada card "Aktivitas Saya", dihitung dari data yang tersedia.
class _HomeStats {
  const _HomeStats({
    required this.activeSubmissions,
    required this.pendingApprovals,
    required this.hasActiveTrip,
    required this.historyCount,
  });

  final int activeSubmissions;
  final int pendingApprovals;
  final bool hasActiveTrip;
  final int historyCount;
}

class _MyActivity extends StatelessWidget {
  const _MyActivity({
    required this.compact,
    required this.stats,
    required this.onSubmissionTap,
    required this.onApprovalTap,
    required this.onActiveTripTap,
    required this.onHistoryTap,
  });

  final bool compact;
  final _HomeStats stats;
  final VoidCallback onSubmissionTap;
  final VoidCallback onApprovalTap;
  final VoidCallback onActiveTripTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActivityCard(
            icon: Icons.send_rounded,
            iconColor: const Color(0xFF3B82F6),
            backgroundColor: const Color(0xFFEFF6FF),
            borderColor: const Color(0xFFCFE2FF),
            title: 'Pengajuan\nAktif',
            number: '${stats.activeSubmissions}',
            compact: compact,
            onTap: onSubmissionTap,
          ),
        ),
        SizedBox(width: compact ? 5 : 7),
        Expanded(
          child: _ActivityCard(
            icon: Icons.schedule_rounded,
            iconColor: const Color(0xFFF2994A),
            backgroundColor: const Color(0xFFFFF6EE),
            borderColor: const Color(0xFFFFE0C2),
            title: 'Menunggu\nPersetujuan',
            number: '${stats.pendingApprovals}',
            compact: compact,
            onTap: onApprovalTap,
          ),
        ),
        SizedBox(width: compact ? 5 : 7),
        Expanded(
          child: _ActivityCard(
            icon: Icons.directions_car_rounded,
            iconColor: const Color(0xFF27AE60),
            backgroundColor: const Color(0xFFEFFAF3),
            borderColor: const Color(0xFFCDEEDB),
            title: 'Perjalanan\nAktif',
            number: stats.hasActiveTrip ? '1' : '0',
            compact: compact,
            onTap: onActiveTripTap,
          ),
        ),
        SizedBox(width: compact ? 5 : 7),
        Expanded(
          child: _ActivityCard(
            icon: Icons.check_circle_rounded,
            iconColor: const Color(0xFFB429CE),
            backgroundColor: const Color(0xFFFBF0FD),
            borderColor: const Color(0xFFF0D0F8),
            title: 'Riwayat',
            number: '${stats.historyCount}',
            compact: compact,
            onTap: onHistoryTap,
          ),
        ),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.number,
    required this.compact,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final String number;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: compact ? 70 : 76,
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: compact ? 16 : 18),
            const SizedBox(height: 3),
            Flexible(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF5C6670),
                  fontSize: 7,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              number,
              style: TextStyle(
                color: iconColor,
                fontSize: compact ? 13 : 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestActivityHeader extends StatelessWidget {
  const _LatestActivityHeader({required this.onViewAll});

  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Judul mendapat porsi lebih besar, link "Lihat Semua" memakai
        // `Expanded` + `Align` supaya kontennya benar-benar rata kanan
        // dan tidak ikut melebar melewati tepi layar.
        const Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: _SectionTitle('Aktivitas Terakhir'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: onViewAll,
              behavior: HitTestBehavior.opaque,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Lihat Semua',
                        maxLines: 1,
                        style: TextStyle(
                          color: Color(0xFF0B75D1),
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Color(0xFF0B75D1), size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.title,
    required this.date,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    this.onTap,
  });

  final String title;
  final String date;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD8DDE2)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFF0B75D1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car,
                  color: Colors.white,
                  size: 17,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF20252B),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF77818B),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
