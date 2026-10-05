import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/admin_dashboard.dart';
import '../../models/vehicle_loan.dart';
import '../../state/admin_loan_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_bottom_navigation.dart';
import '../../widgets/admin_header_actions.dart';
import '../../widgets/admin_loan_detail_widgets.dart';
import 'admin_driver_confirm_page.dart';
import 'admin_navigation.dart';

/// Halaman Detail Peminjaman untuk Admin.
///
/// Satu halaman dipakai untuk semua varian supaya status, driver, dan data
/// selalu berasal dari satu sumber ([AdminLoanState]) dan tidak bisa berbeda
/// antar halaman. Judul dan isi menyesuaikan kondisi peminjaman:
/// - Menunggu + Motor  -> "Detail Peminjaman Motor"
/// - Menunggu + Mobil  -> "Detail Peminjaman Mobil"
/// - Sudah diputuskan   -> "Detail Peminjaman Disetujui" / "Ditolak"
class AdminLoanDetailPage extends StatelessWidget {
  const AdminLoanDetailPage({super.key, required this.loanId});

  /// Id peminjaman; datanya selalu dibaca dari state supaya perubahan status
  /// dan driver langsung terlihat.
  final String loanId;

  /// Judul sesuai status dan jenis kendaraan.
  static String titleFor(VehicleLoan loan) => switch (loan.status) {
    AdminLoanStatus.menunggu => loan.isMobil
        ? 'Detail Peminjaman Mobil'
        : 'Detail Peminjaman Motor',
    AdminLoanStatus.disetujui => 'Detail Peminjaman Disetujui',
    AdminLoanStatus.ditolak => 'Detail Peminjaman Ditolak',
  };

  @override
  Widget build(BuildContext context) {
    final state = AdminLoanStateScope.of(context);
    final loan = state.byId(loanId);

    // Data peminjaman selalu ada selama halaman ini terbuka; kalau somehow
    // hilang, tampilkan pesan singkat.
    if (loan == null) {
      return const _MissingLoanScaffold();
    }

    final driver = defaultDriverOf(state, loan);
    final decided = !loan.isWaiting;

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
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textStrong,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
          toolbarHeight: 44,
          leading: IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, size: 20),
            tooltip: 'Kembali',
          ),
          title: Text(
            titleFor(loan),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: const [AdminHeaderActions()],
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminLoanVehicleCard(loan: loan),
                      const SizedBox(height: 16),
                      AdminInfoCard(child: AdminLoanInfoSection(loan: loan)),

                      // Driver hanya relevan untuk mobil, dan tetap ditampilkan
                      // setelah disetujui supaya Admin tahu siapa Assigned.
                      if (loan.isMobil) ...[
                        const SizedBox(height: 16),
                        _DriverSection(
                          loan: loan,
                          driverName: driver?.name,
                          driverAvailable: driver?.isSelectable ?? false,
                          onChange: () => _openDriverConfirm(context, loan),
                        ),
                      ],

                      const SizedBox(height: 16),
                      AdminInfoCard(
                        child: AdminLoanStatusSection(loan: loan),
                      ),

                      if (decided) ...[
                        const SizedBox(height: 16),
                        _DecisionNotice(loan: loan, driverName: driver?.name),
                      ],

                      if (!decided) ...[
                        const SizedBox(height: 18),
                        _DecisionButtons(
                          loan: loan,
                          driverAvailable:
                              driver != null && driver.isSelectable,
                          onReject: () => _reject(context, state, loan),
                          onApprove: () => _approve(context, state, loan),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AdminBottomNavigation(
          selectedIndex: AdminShellPage.indexBeranda,
          onSelected: (index) => openAdminTab(context, index: index),
        ),
      ),
    );
  }

  void _openDriverConfirm(BuildContext context, VehicleLoan loan) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminDriverConfirmPage(loanId: loan.id),
      ),
    );
  }

  void _reject(BuildContext context, AdminLoanState state, VehicleLoan loan) {
    state.reject(loan.id);
    _notify(context, 'Peminjaman ditolak.');
  }

  void _approve(BuildContext context, AdminLoanState state, VehicleLoan loan) {
    final driver = defaultDriverOf(state, loan);

    // Mobil wajib punya driver yang tersedia sebelum disetujui.
    if (loan.isMobil && (driver == null || !driver.isSelectable)) {
      _notify(
        context,
        'Pilih driver terlebih dahulu sebelum menyetujui peminjaman.',
      );
      _openDriverConfirm(context, loan);
      return;
    }

    state.approve(loan.id, driverId: loan.isMobil ? driver!.id : null);
    _notify(
      context,
      loan.isMobil
          ? 'Peminjaman disetujui. Driver: ${driver!.name}.'
          : 'Peminjaman motor telah disetujui.',
    );
  }

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}


/// Blok driver untuk peminjaman mobil, dengan tombol "Ganti Driver".
class _DriverSection extends StatelessWidget {
  const _DriverSection({
    required this.loan,
    required this.driverName,
    required this.driverAvailable,
    required this.onChange,
  });

  final VehicleLoan loan;
  final String? driverName;
  final bool driverAvailable;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final hasDriver = driverName != null && driverName!.isNotEmpty;

    return AdminInfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car,
                size: 13,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Driver',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 8,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                height: 24,
                child: ElevatedButton(
                  onPressed: onChange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 7.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Ganti Driver'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasDriver)
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 13,
                  color: Color(0xFF16813B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    driverName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textStrong,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (!driverAvailable)
                  const Text(
                    '• Sedang Bertugas',
                    style: TextStyle(color: Color(0xFFB27A00), fontSize: 7.5),
                  ),
              ],
            )
          else
            const Text(
              'Belum ada driver. Pilih driver sebelum menyetujui peminjaman.',
              style: TextStyle(
                color: Color(0xFFB27A00),
                fontSize: 8.5,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }
}

/// Dua tombol aksi: Tolak (merah) dan Setujui (biru).
class _DecisionButtons extends StatelessWidget {
  const _DecisionButtons({
    required this.loan,
    required this.driverAvailable,
    required this.onReject,
    required this.onApprove,
  });

  final VehicleLoan loan;
  final bool driverAvailable;
  final VoidCallback onReject;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: onReject,
              icon: const Icon(Icons.close, size: 14),
              label: const Text('Tolak'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: onApprove,
              icon: const Icon(Icons.check, size: 14),
              label: const Text('Setujui'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Kotak informasi setelah status sudah diputuskan.
class _DecisionNotice extends StatelessWidget {
  const _DecisionNotice({required this.loan, required this.driverName});

  final VehicleLoan loan;
  final String? driverName;

  @override
  Widget build(BuildContext context) {
    final approved = loan.status == AdminLoanStatus.disetujui;
    final (background, border, icon) = approved
        ? (
            const Color(0xFFFDF3DC),
            const Color(0xFFF0DCB4),
            Icons.check_circle,
          )
        : (
            const Color(0xFFFBE7E5),
            const Color(0xFFF3CFCC),
            Icons.cancel,
          );

    final message = approved
        ? (loan.isMobil
              ? 'Peminjaman telah disetujui. Driver: '
                    '${driverName ?? '-'}.\nSilakan hubungi peminjam untuk '
                    'konfirmasi pengambilan kendaraan.'
              : 'Peminjaman motor telah disetujui.\nSilakan hubungi peminjam '
                    'untuk konfirmasi pengambilan kendaraan.')
        : 'Peminjaman telah ditolak.\nPeminjam sudah mendapat pemberitahuan.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF7A5B10)),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontSize: 9,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cadangan kalau data peminjaman tidak ditemukan di state.
class _MissingLoanScaffold extends StatelessWidget {
  const _MissingLoanScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Kembali',
        ),
        title: const Text('Detail Peminjaman'),
      ),
      body: const Center(
        child: Text(
          'Data peminjaman tidak ditemukan',
          style: TextStyle(color: AppColors.textSubtle, fontSize: 10),
        ),
      ),
    );
  }
}
