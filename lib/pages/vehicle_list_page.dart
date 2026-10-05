import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vehicle_data.dart';
import '../models/vehicle.dart';
import '../state/loan_state.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_filter_bar.dart';
import 'loan_application_page.dart';

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final _searchController = TextEditingController();

  VehicleType? _selectedType;
  VehicleStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectType(VehicleType? type) {
    setState(() {
      _selectedType = type;
      if (type == null) {
        _selectedStatus = null;
      }
    });
  }

  void _selectStatus(VehicleStatus status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  List<Vehicle> get _filteredVehicles {
    final query = _searchQuery.trim().toLowerCase();

    return dummyVehicles.where((vehicle) {
      final matchesType =
          _selectedType == null || vehicle.type == _selectedType;
      final matchesStatus =
          _selectedStatus == null || vehicle.status == _selectedStatus;
      final matchesSearch =
          query.isEmpty || vehicle.searchableText.contains(query);

      return matchesType && matchesStatus && matchesSearch;
    }).toList();
  }

  void _openVehicle(Vehicle vehicle) {
    if (vehicle.status != VehicleStatus.tersedia) {
      return;
    }

    LoanStateScope.of(context).selectVehicle(vehicle);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LoanApplicationPage(vehicle: vehicle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = _filteredVehicles;

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
          title: const Text(
            'Daftar Kendaraan Dinas',
            style: TextStyle(
              color: Color(0xFF20252B),
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: SizedBox(
                  height: 46,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Cari Kendaraan...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF8A949E),
                        fontSize: 11,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        size: 19,
                        color: Color(0xFF7D8791),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 42,
                        minHeight: 42,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: Color(0xFFDCE1E6)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: Color(0xFFDCE1E6)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: Color(0xFF0B75D1)),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              VehicleFilterBar(
                selectedType: _selectedType,
                selectedStatus: _selectedStatus,
                onTypeChanged: _selectType,
                onStatusChanged: _selectStatus,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: vehicles.isEmpty
                    ? const Center(
                        child: Text(
                          'Kendaraan tidak ditemukan',
                          style: TextStyle(
                            color: Color(0xFF77818B),
                            fontSize: 11,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                        itemCount: vehicles.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return VehicleCard(
                            vehicle: vehicle,
                            onTap: vehicle.status == VehicleStatus.tersedia
                                ? () => _openVehicle(vehicle)
                                : null,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
