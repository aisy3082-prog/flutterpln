import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/driver_data.dart';
import '../../models/driver.dart';
import '../../models/vehicle_loan.dart';
import '../../state/admin_loan_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_bottom_navigation.dart';
import '../../widgets/admin_header_actions.dart';
import '../../widgets/admin_loan_detail_widgets.dart';
import 'admin_navigation.dart';

/// Halaman "Konfirmasi Driver" untuk peminjaman mobil.
///
/// Driver default kendaraan sudah terpilih otomatis, jadi Admin tidak perlu
/// memilih dari awal — halaman ini dipakai untuk mengganti driver bila perlu
/// dan untuk mengonfirmasi driver yang dipilih.
class AdminDriverConfirmPage extends StatefulWidget {
  const AdminDriverConfirmPage({super.key, required this.loanId});

  final String loanId;

  @override
  State<AdminDriverConfirmPage> createState() =>
      _AdminDriverConfirmPageState();
}

class _AdminDriverConfirmPageState extends State<AdminDriverConfirmPage> {
  final _searchController = TextEditingController();
  String _query = '';

  /// Id driver yang sedang dipilih. Awalnya memakai driver yang sudah
  /// ditetapkan pada peminjaman, atau driver default kendaraan.
  String? _selectedDriverId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Awalnya: driver yang sudah tersimpan, kalau tidak ada pakai default.
  String? _initialDriverId(VehicleLoan loan, AdminLoanState state) =>
      loan.driverId ?? defaultDriverOf(state, loan)?.id;

  List<Driver> get _visibleDrivers {
    final keyword = _query.trim().toLowerCase();
    if (keyword.isEmpty) {
      return dummyDrivers;
    }
    return dummyDrivers
        .where((driver) => driver.name.toLowerCase().contains(keyword))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final state = AdminLoanStateScope.of(context);
    final loan = state.byId(widget.loanId);

    if (loan == null) {
      return const _MissingLoanScaffold();
    }

    // Driver terpilih: kalau Admin belum memilih, pakai driver yang sudah
    // ditetapkan atau driver default kendaraan.
    final selectedId = _selectedDriverId ?? _initialDriverId(loan, state);
    final selected = selectedId == null ? null : driverById(selectedId);

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
          title: const Text(
            'Konfirmasi Driver',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
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
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AdminLoanVehicleCard(loan: loan),
                      const SizedBox(height: 16),
                      AdminInfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AdminDetailSectionTitle('Data Peminjam'),
                            const SizedBox(height: 10),
                            AdminInfoItem(
                              icon: Icons.person_outline,
                              label: 'Nama Peminjam',
                              value: loan.borrowerName,
                            ),
                            const SizedBox(height: 9),
                            AdminInfoItem(
                              icon: Icons.phone_outlined,
                              label: 'Nomor HP',
                              value: loan.borrowerPhone,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      AdminInfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const AdminDetailSectionTitle('Data Driver'),
                            const SizedBox(height: 10),
                            if (selected == null)
                              const Text(
                                'Belum ada driver. Pilih salah satu di bawah.',
                                style: TextStyle(
                                  color: Color(0xFFB27A00),
                                  fontSize: 8.5,
                                  height: 1.4,
                                ),
                              )
                            else
                              Row(
                                children: [
                                  _DriverAvatar(driver: selected, size: 32),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          selected.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: AppColors.textStrong,
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        _DriverStatusDot(
                                          isAvailable:
                                              selected.isSelectable,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 14),
                            const AdminDetailSectionTitle('Jadwal'),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 13,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    loan.scheduleLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textStrong,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DriverSearchField(
                        controller: _searchController,
                        onChanged: (value) =>
                            setState(() => _query = value),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Daftar Driver Tersedia',
                        style: TextStyle(
                          color: AppColors.textStrong,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildDriverRows(context, selectedId),
                    ],
                  ),
                ),
              ),
              // Tombol konfirmasi tetap terlihat tanpa perlu menggulir.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.borderSoft)),
                ),
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton.icon(
                    key: const ValueKey('admin_driver_confirm_button'),
                    onPressed: selected == null || !selected.isSelectable
                        ? null
                        : () => _confirm(context, state, loan, selected),
                    icon: const Icon(Icons.check, size: 15),
                    label: const Text('Konfirmasi & Setujui Peminjaman'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFB9CBDD),
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
          ),
        ),
        bottomNavigationBar: AdminBottomNavigation(
          selectedIndex: AdminShellPage.indexBeranda,
          onSelected: (index) => openAdminTab(context, index: index),
        ),
      ),
    );
  }

  List<Widget> _buildDriverRows(BuildContext context, String? selectedId) {
    final drivers = _visibleDrivers;
    if (drivers.isEmpty) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Center(
            child: Text(
              'Driver tidak ditemukan',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 9),
            ),
          ),
        ),
      ];
    }

    return [
      for (final driver in drivers) ...[
        _DriverRow(
          driver: driver,
          isSelected: driver.id == selectedId,
          onPick: driver.isSelectable
              ? () => setState(() => _selectedDriverId = driver.id)
              : null,
        ),
        if (driver != drivers.last) const SizedBox(height: 8),
      ],
    ];
  }

  void _confirm(
    BuildContext context,
    AdminLoanState state,
    VehicleLoan loan,
    Driver driver,
  ) {
    // Simpan driver, ubah status jadi disetujui, lalu kembali ke Detail.
    state.setDriver(loan.id, driver.id);
    state.approve(loan.id, driverId: driver.id);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Peminjaman disetujui. Driver: ${driver.name}.')),
      );
  }
}

class _DriverSearchField extends StatelessWidget {
  const _DriverSearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: Color(0xFF2E3742), fontSize: 10),
        decoration: InputDecoration(
          hintText: 'Cari Nama Driver ....',
          hintStyle: const TextStyle(color: Color(0xFF8A949E), fontSize: 10),
          prefixIcon: const Icon(Icons.search, size: 17),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 38,
            minHeight: 38,
          ),
          isDense: true,
          filled: true,
          fillColor: const Color(0xFFF4F8FC),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          border: _border(AppColors.borderSoft),
          enabledBorder: _border(AppColors.borderSoft),
          focusedBorder: _border(AppColors.primary),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: color),
  );
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.driver,
    required this.isSelected,
    required this.onPick,
  });

  final Driver driver;
  final bool isSelected;
  final VoidCallback? onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.borderSoft,
          width: isSelected ? 1.4 : 1,
        ),
      ),
      child: Row(
        children: [
          _DriverAvatar(driver: driver, size: 34),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                _DriverStatusDot(isAvailable: driver.isSelectable),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 24,
            // Driver yang sedang bertugas tidak bisa dipilih.
            child: ElevatedButton(
              key: ValueKey('admin_driver_pick_${driver.id}'),
              onPressed: onPick,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFE3E7EB),
                disabledForegroundColor: const Color(0xFF9AA3AB),
                elevation: 0,
                padding: EdgeInsets.zero,
                minimumSize: const Size(52, 24),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                textStyle: const TextStyle(
                  fontSize: 7.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(driver.isSelectable ? 'Pilih' : 'Penuh'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.driver, required this.size});

  final Driver driver;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF3FF),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: ClipOval(
        child: Image.asset(
          driver.photo,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, _, _) => Text(
            driver.initial,
            style: TextStyle(
              color: AppColors.primary,
              fontSize: size * 0.36,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Titik hijau "Tersedia" atau abu-abu "Sedang Bertugas".
class _DriverStatusDot extends StatelessWidget {
  const _DriverStatusDot({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isAvailable
                ? const Color(0xFF35A744)
                : const Color(0xFF9AA3AB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isAvailable ? 'Tersedia' : 'Sedang Bertugas',
          style: TextStyle(
            color: isAvailable
                ? const Color(0xFF16813B)
                : const Color(0xFF77818B),
            fontSize: 7.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
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
        title: const Text('Konfirmasi Driver'),
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
