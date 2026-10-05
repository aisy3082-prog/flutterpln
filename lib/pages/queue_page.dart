import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/whatsapp_launcher.dart';
import '../models/vehicle.dart';
import '../state/loan_state.dart';
import '../utils/app_navigation.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/loan_progress.dart';
import '../widgets/route_map_placeholder.dart';
import '../widgets/state_views.dart';
import 'trip_detail_page.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  @override
  Widget build(BuildContext context) {
    final loanState = LoanStateScope.of(context);
    final vehicle = loanState.currentVehicle;
    final draft = loanState.draft;
    final status = loanState.status;

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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, size: 20),
            tooltip: 'Kembali',
          ),
          title: const Text(
            'Antrean Saya',
            style: TextStyle(
              color: Color(0xFF20252B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: status == LoanStatus.selesai
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFDCE1E6)),
                    ),
                    child: const EmptyStateView(
                      title: 'Tidak ada pengajuan',
                      description:
                          'Saat ini Anda tidak melakukan pengajuan peminjaman kendaraan.',
                      icon: Icons.description_outlined,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LoanProgress(status: status),
                      const SizedBox(height: 8),
                      _QueueCard(
                        vehicle: vehicle,
                        status: status,
                        draft: draft,
                      ),
                    ],
                  ),
                ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          // Antrean Saya dibuka dari Beranda, jadi menu Beranda yang aktif.
          selectedTab: AppTab.beranda,
        ),
      ),
    );
  }
}

class _QueueCard extends StatelessWidget {
  const _QueueCard({
    required this.vehicle,
    required this.status,
    required this.draft,
  });

  final Vehicle vehicle;
  final LoanStatus status;
  final LoanDraft? draft;

  bool get _hasDriver =>
      status == LoanStatus.disetujui || status == LoanStatus.dalamPerjalanan;

  bool get _isFinished => status == LoanStatus.selesai;

  @override
  Widget build(BuildContext context) {
    final borrowDate = draft?.borrowDate ?? '21 Sep 2026';
    final borrowTime = draft?.borrowTime ?? '09.00';
    final returnDate = draft?.returnDate ?? '21 Sep 2026';
    final returnTime = draft?.returnTime ?? '15.00';
    final destination = draft?.destination ?? 'Bala Desa Gkreeg';
    final passengers = draft?.passengerCount ?? '4';
    final purpose = draft?.purpose ?? 'Kegiatan monitoring lapangan';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E5E8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 82,
                height: 62,
                child: Image.asset(
                  vehicle.imageAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      vehicle.name,
                      style: const TextStyle(
                        color: Color(0xFF20252B),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${vehicle.code}   ${vehicle.plateNumber}',
                      style: const TextStyle(
                        color: Color(0xFF65707A),
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
              _QueueStatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE7EAED)),
          const SizedBox(height: 8),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Pinjam',
            value: '$borrowDate  $borrowTime',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Tanggal Kembali',
            value: '$returnDate  $returnTime',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Tujuan',
            value: destination,
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.people_outline,
            label: 'Jumlah Penumpang',
            value: '$passengers Orang',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            icon: Icons.assignment_outlined,
            label: 'Keperluan',
            value: purpose,
          ),
          if (_hasDriver) ...[
            const SizedBox(height: 8),
            const Divider(height: 1, color: Color(0xFFE7EAED)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 17,
                  color: Color(0xFF0B75D1),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Driver',
                        style: TextStyle(color: Color(0xFF65707A), fontSize: 8),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        LoanState.driver.name,
                        style: const TextStyle(
                          color: Color(0xFF20252B),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _contactDriver(context),
                  icon: const Icon(
                    Icons.phone_in_talk_outlined,
                    size: 19,
                    color: Color(0xFF0B75D1),
                  ),
                  tooltip: 'Hubungi driver',
                ),
              ],
            ),
            const SizedBox(height: 8),
            const RouteMapPlaceholder(height: 145),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TripDetailPage(vehicle: vehicle),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B75D1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Detail Perjalanan'),
              ),
            ),
          ],
          if (_isFinished) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricBox(label: 'Jarak', value: '45 Km'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MetricBox(label: 'Durasi', value: '1 jam 20 menit'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.badge_outlined,
                  size: 17,
                  color: Color(0xFF0B75D1),
                ),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Driver: Budi Santoso',
                    style: TextStyle(
                      color: Color(0xFF20252B),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _contactDriver(BuildContext context) async {
    final opened = await openDriverWhatsApp();
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('WhatsApp tidak tersedia pada perangkat ini.'),
        ),
      );
    }
  }
}

class _QueueStatusBadge extends StatelessWidget {
  const _QueueStatusBadge({required this.status});

  final LoanStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, label) = switch (status) {
      LoanStatus.pengajuan => (
        const Color(0xFF0B75D1),
        Colors.white,
        'Menunggu persetujuan',
      ),
      LoanStatus.antrean => (
        const Color(0xFFFFE7A8),
        const Color(0xFF9A6A00),
        'Antrean',
      ),
      LoanStatus.disetujui => (
        const Color(0xFFBFE9FF),
        const Color(0xFF0B75D1),
        'Disetujui',
      ),
      LoanStatus.dalamPerjalanan => (
        const Color(0xFFC8F0CE),
        const Color(0xFF1E9B3B),
        'Dipinjam',
      ),
      LoanStatus.selesai => (
        const Color(0xFFC8F0CE),
        const Color(0xFF1E9B3B),
        'Selesai',
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: const Color(0xFF65707A)),
        const SizedBox(width: 7),
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF65707A), fontSize: 8),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2E3742),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  const _MetricBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: const Color(0xFFE1E5E8)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF77818B), fontSize: 8),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF20252B),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
