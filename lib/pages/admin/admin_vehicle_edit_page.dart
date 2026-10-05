import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/vehicle.dart';
import '../../state/admin_vehicle_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_vehicle_detail_widgets.dart';
import '../../widgets/admin_vehicle_form_fields.dart';

/// Halaman "Edit Kendaraan" milik Admin.
///
/// Field sudah terisi dari kendaraan yang dipilih. Tombol Simpan menulis
/// perubahan ke [AdminVehicleState] supaya daftar dan halaman detail langsung
/// ikut berubah. Batal Simply membatalkan tanpa menyimpan.
class AdminVehicleEditPage extends StatefulWidget {
  const AdminVehicleEditPage({super.key, required this.vehicleCode});

  final String vehicleCode;

  @override
  State<AdminVehicleEditPage> createState() => _AdminVehicleEditPageState();
}

class _AdminVehicleEditPageState extends State<AdminVehicleEditPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _plateController;
  late final TextEditingController _seatController;
  late final TextEditingController _yearController;

  late String _engineCapacity;
  late VehicleStatus _status;

  Vehicle? _source;

  @override
  void initState() {
    super.initState();
    // Nilai awal diambil nanti saat state tersedia; diisi placeholder dulu
    // supaya controller tidak null.
    _nameController = TextEditingController();
    _plateController = TextEditingController();
    _seatController = TextEditingController();
    _yearController = TextEditingController();
    _engineCapacity = AdminEngineCapacityDropdown.mobilOptions.first;
    _status = VehicleStatus.tersedia;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final vehicle = AdminVehicleStateScope.of(
      context,
    ).byCode(widget.vehicleCode);
    if (vehicle == null || _source?.code == vehicle.code) {
      return;
    }
    // Isi form sekali saja, dari kendaraan yang sedang dibuka.
    _source = vehicle;
    _nameController.text = vehicle.name;
    _plateController.text = vehicle.plateNumber;
    _seatController.text = vehicle.capacity?.toString() ?? '';
    _yearController.text = '${vehicle.productionYear}';
    _engineCapacity = vehicle.engineCapacity;
    _status = vehicle.status;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _plateController.dispose();
    _seatController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  String? _required(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Wajib diisi' : null;

  String? _number(String? value) {
    final required = _required(value);
    if (required != null) {
      return required;
    }
    return int.tryParse(value!.trim()) == null ? 'Masukkan angka' : null;
  }

  @override
  Widget build(BuildContext context) {
    final vehicle = _source;

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
        resizeToAvoidBottomInset: true,
        appBar: const AdminVehicleAppBar(title: 'Edit Kendaraan'),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            // ListView supaya form tetap bisa digulir saat keyboard muncul.
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
              children: [
                if (vehicle != null) ...[
                  AdminVehicleSummaryCard(vehicle: vehicle),
                  const SizedBox(height: 16),
                ],
                AdminTextFieldBox(
                  label: 'Nama Kendaraan',
                  hint: 'Toyota Fortuner',
                  controller: _nameController,
                  validator: _required,
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Nomor Plat',
                        hint: 'B 2345 XX',
                        controller: _plateController,
                        validator: _required,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminEngineCapacityDropdown(
                        value: _engineCapacity,
                        type: vehicle?.type ?? VehicleType.mobil,
                        onChanged: (value) =>
                            setState(() => _engineCapacity = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Jumlah Kursi',
                        hint: '7 seat',
                        controller: _seatController,
                        keyboardType: TextInputType.number,
                        validator: _number,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextFieldBox(
                        label: 'Tahun Produksi',
                        hint: '2020',
                        controller: _yearController,
                        keyboardType: TextInputType.number,
                        validator: _number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AdminVehicleStatusSelector(
                  selected: _status,
                  onChanged: (value) => setState(() => _status = value),
                ),
                const SizedBox(height: 20),
                AdminFormActionButtons(
                  onCancel: _cancel,
                  onSave: _saveVehicle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _cancel() => Navigator.of(context).maybePop();

  void _saveVehicle() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final current = _source;
    if (current == null) {
      return;
    }

    AdminVehicleStateScope.of(context).updateVehicle(
      current.copyWith(
        name: _nameController.text.trim(),
        plateNumber: _plateController.text.trim(),
        capacity: int.tryParse(_seatController.text.trim()),
        engineCapacity: _engineCapacity,
        productionYear:
            int.tryParse(_yearController.text.trim()) ??
            current.productionYear,
        status: _status,
      ),
    );

    Navigator.of(context).maybePop();
  }
}

