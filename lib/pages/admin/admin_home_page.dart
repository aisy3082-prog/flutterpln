import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/admin_dashboard_data.dart';
import '../../models/admin_dashboard.dart';
import '../../models/admin_profile.dart';
import '../../models/vehicle.dart';
import '../../utils/constants.dart';
import 'admin_loan_list_page.dart';
import 'admin_navigation.dart';

/// Beranda Admin: sapaan, dashboard statistik, dan peminjaman terbaru.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({
    super.key,
    this.profile = dummyAdminProfile,
    this.stats = dummyAdminStats,
    this.loans = dummyAdminLoans,
  });

  final AdminProfile profile;
  final List<AdminStat> stats;
  final List<AdminLoan> loans;

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
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 360;
              final horizontalPadding = compact ? 12.0 : 16.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  4,
                  horizontalPadding,
                  AppSpacing.pageBottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AdminHeader(profile: profile, compact: compact),
                    const SizedBox(height: 14),
                    Text(
                      'Halo, ${profile.name}',
                      style: const TextStyle(
                        color: Color(0xFF20252B),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kelola semua peminjaman kendaraan di sini',
                      style: TextStyle(
                        color: Color(0xFF77818B),
                        fontSize: 9,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _StatsGrid(stats: stats, compact: compact),
                    const SizedBox(height: 16),
                    const _SectionHeader('Peminjaman Terbaru'),
                    const SizedBox(height: 10),
                    _LoanList(loans: loans, compact: compact),
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

/// Baris atas: panah kembali, judul "Admin", lalu ikon notifikasi dan avatar.
class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.profile, required this.compact});

  final AdminProfile profile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Row(
        children: [
          // Tombol kembali mengikuti struktur aplikasi: kalau sudah menjadi root
          // (dipanggil lewat openAdminAsRoot) tidak ada yang bisa dipop,
          // sehingga tombolnya disembunyikan.
          if (Navigator.of(context).canPop())
            _HeaderIcon(
              icon: Icons.chevron_left,
              tooltip: 'Kembali',
              onPressed: () => Navigator.of(context).maybePop(),
            )
          else
            const SizedBox(width: 4),
          const SizedBox(width: 4),
          const Text(
            'Admin',
            style: TextStyle(
              color: Color(0xFF20252B),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          _HeaderIcon(
            icon: Icons.notifications_none,
            tooltip: 'Notifikasi',
            onPressed: () => openAdminTab(
              context,
              index: AdminShellPage.indexNotifikasi,
            ),
          ),
          const SizedBox(width: 6),
          // Seluruh cluster avatar + nama + chevron adalah satu target tap
          // ke Profil. Sebelumnya hanya lingkaran avatar yang bisa ditekan,
          // sehingga menekan nama "Admin" atau chevron tidak melakukan apa-apa.
          _ProfileEntry(
            initial: profile.initial,
            name: profile.name,
            onTap: () => openAdminTab(
              context,
              index: AdminShellPage.indexProfil,
            ),
          ),
        ],
      ),
    );
  }
}

/// Cluster profil di header: avatar lingkaran + nama + chevron.
///
/// Dibungkus satu [InkWell] supaya seluruh area bisa ditekan, bukan hanya
/// avatar-nya.
class _ProfileEntry extends StatelessWidget {
  const _ProfileEntry({
    required this.initial,
    required this.name,
    required this.onTap,
  });

  final String initial;
  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('admin_header_profile_entry'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MiniAvatar(initial: initial),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF3E464E),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF9AA3AB),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(icon, size: 20, color: const Color(0xFF3E464E)),
          ),
        ),
      ),
    );
  }
}

/// Avatar lingkaran kecil berisi inisial, seperti di desain.
///
/// Area tap-nya ditangani [_ProfileEntry] yang membungkusnya.
class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            initial,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Grid 2x2 kartu statistik.
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.compact});

  final List<AdminStat> stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row * 2 < stats.length; row++) ...[
          if (row > 0) const SizedBox(height: 8),
          // `IntrinsicHeight` diperlukan karena `stretch` di dalam area
          // scroll akan mendapat tinggi tak terbatas tanpa ini.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _StatCard(stats: stats[row * 2], compact: compact),
                ),
                SizedBox(width: compact ? 6 : 8),
                // Baris terakhir boleh berisi satu kartu saja.
                if (row * 2 + 1 < stats.length)
                  Expanded(
                    child: _StatCard(
                      stats: stats[row * 2 + 1],
                      compact: compact,
                    ),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stats, required this.compact});

  final AdminStat stats;
  final bool compact;

  /// Card "Peminjaman Mobil" dan "Peminjaman Motor" bisa diketuk untuk membuka
  /// Daftar Peminjaman Terbaru dengan filter yang sesuai. Kartu lain belum
  /// punya tujuan sehingga hanya tampil sebagai informasi.
  bool get _opensLoanList =>
      stats.title == 'Peminjaman Mobil' || stats.title == 'Peminjaman Motor';

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: EdgeInsets.all(compact ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 30 : 34,
            height: compact ? 30 : 34,
            decoration: BoxDecoration(
              color: stats.tint.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              stats.icon,
              size: compact ? 16 : 18,
              color: stats.tint.foreground,
            ),
          ),
          SizedBox(width: compact ? 7 : 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stats.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF20252B),
                    fontSize: compact ? 8.5 : 9,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${stats.value}',
                  style: TextStyle(
                    color: stats.tint.foreground,
                    fontSize: compact ? 15 : 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  stats.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF77818B),
                    fontSize: 7.5,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!_opensLoanList) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _openList(context),
        borderRadius: BorderRadius.circular(10),
        child: card,
      ),
    );
  }

  void _openList(BuildContext context) {
    final filter = stats.title == 'Peminjaman Motor'
        ? VehicleType.motor
        : VehicleType.mobil;
    // Halaman daftarnya sama persis; hanya filter awal yang berbeda.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminLoanListPage(initialFilter: filter),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Peminjaman Terbaru',
              style: TextStyle(
                color: Color(0xFF20252B),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _showAllLoans(context),
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
                          color: AppColors.primary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAllLoans(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminLoanListPage()),
    );
  }
}

class _LoanList extends StatelessWidget {
  const _LoanList({required this.loans, required this.compact});

  final List<AdminLoan> loans;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Column(
        children: [
          for (var i = 0; i < loans.length; i++) ...[
            if (i > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFEDEFF1),
              ),
            _LoanRow(loan: loans[i], compact: compact),
          ],
        ],
      ),
    );
  }
}

class _LoanRow extends StatelessWidget {
  const _LoanRow({required this.loan, required this.compact});

  final AdminLoan loan;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isMobil = loan.vehicleType == VehicleType.mobil;
    final tint = isMobil ? AppColors.primary : const Color(0xFF35A744);
    final (pillBackground, pillForeground) = switch (loan.status) {
      AdminLoanStatus.menunggu => (
        const Color(0xFFDDE9FB),
        const Color(0xFF0B75D1),
      ),
      AdminLoanStatus.disetujui => (
        const Color(0xFFB8F0C0),
        const Color(0xFF16813B),
      ),
      AdminLoanStatus.ditolak => (
        const Color(0xFFF9D5D5),
        const Color(0xFFD64B4B),
      ),
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        children: [
          Container(
            width: compact ? 30 : 34,
            height: compact ? 30 : 34,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(
              isMobil ? Icons.directions_car : Icons.two_wheeler,
              size: compact ? 16 : 18,
              color: Colors.white,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loan.vehicleName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF20252B),
                    fontSize: compact ? 9.5 : 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  loan.dateTime,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pillBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              loan.status.label,
              style: TextStyle(
                color: pillForeground,
                fontSize: 7.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
