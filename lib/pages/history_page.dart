import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/history_models.dart';
import '../models/vehicle.dart';
import '../services/history_service.dart';
import '../state/loan_state.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/app_bottom_navigation.dart';
import '../widgets/async_state_builder.dart';
import '../widgets/energy_history_card.dart';
import '../widgets/history_vehicle_card.dart';
import '../widgets/tab_selector.dart';
import '../widgets/travel_summary_card.dart';
import '../widgets/trip_history_card.dart';

/// Riwayat Kendaraan dengan dua kategori:
/// Perjalanan (ringkasan + daftar perjalanan) dan Energi (BBM / Listrik).
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key, this.service = const DummyHistoryService()});

  final HistoryService service;

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const int _travelTab = 0;

  int _selectedTab = _travelTab;
  int _energyTab = 0;

  late Future<DataResult<List<TripHistory>>> _tripsFuture;
  late Future<DataResult<List<EnergyHistory>>> _energyFuture;

  @override
  void initState() {
    super.initState();
    _tripsFuture = widget.service.loadTrips();
    _energyFuture = widget.service.loadEnergy(type: HistoryEnergyType.bbm);
  }

  void _reloadTrips() {
    setState(() {
      _tripsFuture = widget.service.loadTrips();
    });
  }

  void _loadEnergy(HistoryEnergyType type) {
    setState(() {
      _energyFuture = widget.service.loadEnergy(type: type);
    });
  }

  void _onEnergyChanged(int index) {
    setState(() {
      _energyTab = index;
    });
    _loadEnergy(index == 0 ? HistoryEnergyType.bbm : HistoryEnergyType.listrik);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Kendaraan listrik otomatis membuka tab Energi/Listrik.
    final vehicle = LoanStateScope.of(context).currentVehicle;
    if (vehicle.energyType == VehicleEnergyType.listrik && _energyTab == 0) {
      _energyTab = 1;
      _energyFuture = widget.service.loadEnergy(
        type: HistoryEnergyType.listrik,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = LoanStateScope.of(context).currentVehicle;

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
            'Riwayat Kendaraan',
            style: TextStyle(
              color: AppColors.textStrong,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pageHorizontal,
                  AppSpacing.xl,
                  AppSpacing.pageHorizontal,
                  0,
                ),
                child: TabSelector(
                  labels: const ['Perjalanan', 'Energi'],
                  selectedIndex: _selectedTab,
                  onChanged: (index) => setState(() => _selectedTab = index),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: _selectedTab == _travelTab
                    ? _buildTravelHistory(context, vehicle)
                    : _buildEnergyHistory(context, vehicle),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const AppBottomNavigation(
          selectedTab: AppTab.beranda,
        ),
      ),
    );
  }

  Widget _buildTravelHistory(BuildContext context, Vehicle vehicle) {
    return FutureBuilder<DataResult<List<TripHistory>>>(
      future: _tripsFuture,
      builder: (context, snapshot) {
        final result = snapshot.connectionState == ConnectionState.done
            ? snapshot.data!
            : const DataResult<List<TripHistory>>.loading();
        return AsyncStateBuilder<List<TripHistory>>(
          result: result,
          onRetry: _reloadTrips,
          emptyTitle: 'Belum ada riwayat perjalanan',
          emptyDescription: 'Riwayat perjalanan kendaraan akan tampil di sini.',
          emptyIcon: Icons.route_outlined,
          builder: (context, trips) {
            final isElectric = vehicle.energyType == VehicleEnergyType.listrik;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pageHorizontal,
                0,
                AppSpacing.pageHorizontal,
                AppSpacing.pageBottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HistoryVehicleCard(vehicle: vehicle),
                  const SizedBox(height: AppSpacing.lg),
                  TravelSummaryCard(
                    tripCount: '30',
                    totalDistance: '1.250 km',
                    energyLabel: isElectric ? 'Total kWh' : 'Total BBM',
                    totalEnergy: isElectric ? '420 kWh' : '150 L',
                    totalCost: isElectric ? 'Rp 630.000' : 'Rp 1.500.000',
                    costLabel: isElectric
                        ? 'Total Biaya Listrik'
                        : 'Total Biaya BBM',
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const Text(
                    'Riwayat Perjalanan',
                    style: TextStyle(
                      color: AppColors.textStrong,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ...trips.map(
                    (history) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: TripHistoryCard(history: history),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEnergyHistory(BuildContext context, Vehicle vehicle) {
    final type = _energyTab == 1
        ? HistoryEnergyType.listrik
        : HistoryEnergyType.bbm;

    return FutureBuilder<DataResult<List<EnergyHistory>>>(
      future: _energyFuture,
      builder: (context, snapshot) {
        // FutureBuilder masih menyimpan data lama selama future baru dimuat,
        // jadi loading diambil dari connectionState, bukan dari data.
        final result = snapshot.connectionState == ConnectionState.done
            ? snapshot.data!
            : const DataResult<List<EnergyHistory>>.loading();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
              ),
              child: TabSelector(
                labels: const ['BBM', 'Listrik'],
                selectedIndex: _energyTab,
                onChanged: _onEnergyChanged,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Expanded(
              child: AsyncStateBuilder<List<EnergyHistory>>(
                result: result,
                onRetry: () => _loadEnergy(type),
                emptyTitle: 'Belum ada riwayat energi',
                emptyDescription:
                    'Riwayat pengisian energi kendaraan akan tampil di sini.',
                emptyIcon: Icons.bolt_outlined,
                builder: (context, records) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      0,
                      AppSpacing.pageHorizontal,
                      AppSpacing.pageBottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HistoryVehicleCard(vehicle: vehicle),
                        const SizedBox(height: AppSpacing.lg),
                        ...records.map(
                          (record) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.xxl,
                            ),
                            child: EnergyHistoryCard(record: record),
                          ),
                        ),
                        FuelProofCard(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Bukti pengisian belum tersedia.',
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
          ],
        );
      },
    );
  }
}
