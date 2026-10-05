import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/vehicle.dart';
import '../../models/vehicle_loan.dart';
import '../../state/admin_loan_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_bottom_navigation.dart';
import '../../widgets/admin_loan_card.dart';
import 'admin_loan_detail_page.dart';
import 'admin_navigation.dart';

/// Halaman "Daftar Peminjaman Terbaru" milik Admin.
///
/// Dibuka dari link "Lihat Semua" dan dari card statistik "Peminjaman Mobil"
/// atau "Peminjaman Motor" di Beranda Admin. Halaman ini berdiri di atas shell,
/// jadi memakai [AdminBottomNavigation] yang sama dengan halaman Admin lain,
/// dan setiap tombolnya meneruskan perpindahan tab lewat [openAdminTab].
class AdminLoanListPage extends StatefulWidget {
  const AdminLoanListPage({
    super.key,
    this.initialFilter,
    this.embedded = false,
  });

  /// Filter jenis kendaraan yang aktif sejak awal. Dipakai saat halaman
  /// dibuka dari card "Peminjaman Mobil"/"Peminjaman Motor" di Beranda.
  final VehicleType? initialFilter;

  /// Kalau true, navbar tidak ditampilkan karena host shell yang menanganinya.
  final bool embedded;

  @override
  State<AdminLoanListPage> createState() => _AdminLoanListPageState();
}

class _AdminLoanListPageState extends State<AdminLoanListPage> {
  final _searchController = TextEditingController();

  String _query = '';

  /// null berarti "Semua".
  late VehicleType? _typeFilter = widget.initialFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Daftar dari state, jadi perubahan status di halaman detail langsung
  /// terlihat di sini.
  List<VehicleLoan> get _filteredLoans {
    final state = AdminLoanStateScope.of(context);
    return state.loans.where((loan) {
      final matchesType =
          _typeFilter == null || loan.vehicleType == _typeFilter;
      return matchesType && loan.matches(_query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });
  }

  void _selectFilter(VehicleType? type) {
    setState(() {
      _typeFilter = type;
    });
  }

  void _openLoan(VehicleLoan loan) {
    // Menuju halaman detail; judul dan isinya menyesuaikan status serta jenis
    // kendaraan, jadi penentuannya cukup satu pintu di sini.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminLoanDetailPage(loanId: loan.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loans = _filteredLoans;

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
            'Daftar Peminjaman Terbaru',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: AppColors.textStrong,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              _SearchField(
                controller: _searchController,
                onChanged: _onSearchChanged,
              ),
              _TypeFilterBar(
                selected: _typeFilter,
                onSelected: _selectFilter,
              ),
              Expanded(
                child: loans.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                        itemCount: loans.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final loan = loans[index];
                          return AdminLoanCard(
                            loan: loan,
                            onTap: () => _openLoan(loan),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: widget.embedded
            // Saat menjadi tab shell, navbar ditangani oleh shell.
            ? null
            : AdminBottomNavigation(
                // Halaman ini bagian dari alur Beranda, jadi tab Beranda
                // yang ditandai aktif.
                selectedIndex: AdminShellPage.indexBeranda,
                onSelected: (index) => openAdminTab(context, index: index),
              ),
      ),
    );
  }
}

/// Search bar di bawah header.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SizedBox(
        height: 40,
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          style: const TextStyle(color: Color(0xFF2E3742), fontSize: 10),
          decoration: InputDecoration(
            hintText: 'Cari Kendaraan....',
            hintStyle: const TextStyle(color: Color(0xFF8A949E), fontSize: 10),
            prefixIcon: const Icon(
              Icons.search,
              size: 18,
              color: Color(0xFF7D8791),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
            isDense: true,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            border: _border(AppColors.borderSoft),
            enabledBorder: _border(AppColors.borderSoft),
            focusedBorder: _border(AppColors.primary),
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(9),
    borderSide: BorderSide(color: color),
  );
}

/// Tiga tombol filter: Semua, Mobil, Motor.
class _TypeFilterBar extends StatelessWidget {
  const _TypeFilterBar({required this.selected, required this.onSelected});

  /// null = "Semua".
  final VehicleType? selected;
  final ValueChanged<VehicleType?> onSelected;

  @override
  Widget build(BuildContext context) {
    const options = <(String, VehicleType?)>[
      ('Semua', null),
      ('Mobil', VehicleType.mobil),
      ('Motor', VehicleType.motor),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          // Expanded dipakai agar ketiga tombol selalu sama lebar dan tidak
          // pernah keluar layar di layar sempit.
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: _FilterButton(
                label: options[i].$1,
                selected: selected == options[i].$2,
                onTap: () => onSelected(options[i].$2),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Material(
        color: selected ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Ink(
            decoration: BoxDecoration(
              color: selected ? AppColors.primary : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.borderSoft,
              ),
            ),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : const Color(0xFF7D8791),
                      fontSize: 9.5,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Tampilan saat pencarian/filter tidak menghasilkan data.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 34,
              color: Color(0xFFB4BCC4),
            ),
            SizedBox(height: AppSpacing.xl),
            Text(
              'Data peminjaman tidak ditemukan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF77818B),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Text(
              'Coba kata kunci lain atau pilih filter Semua.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF9AA3AB), fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
