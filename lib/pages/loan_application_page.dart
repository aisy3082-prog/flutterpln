import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/vehicle_data.dart';
import '../models/vehicle.dart';
import '../state/loan_state.dart';
import 'queue_page.dart';

class LoanApplicationPage extends StatefulWidget {
  const LoanApplicationPage({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  State<LoanApplicationPage> createState() => _LoanApplicationPageState();
}

class _LoanApplicationPageState extends State<LoanApplicationPage> {
  static const Color _primaryBlue = Color(0xFF0B75D1);

  final _formKey = GlobalKey<FormState>();
  final _passengerController = TextEditingController(text: '4');
  final _purposeController = TextEditingController(
    text: 'Kegiatan monitoring lapangan',
  );

  VehicleType? _selectedType;
  Vehicle? _selectedVehicle;
  String _borrowDate = '21 Sep 2026';
  String _borrowTime = '09.00';
  String _returnDate = '21 Sep 2026';
  String _returnTime = '15.00';
  String _pickupLocation = 'Pilih lokasi peta';
  String _destination = 'Bala Desa Gkreeg';
  String? _errorMessage;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      return;
    }

    if (widget.vehicle != null) {
      _selectedType = widget.vehicle!.type;
      _selectedVehicle = widget.vehicle;
    } else {
      _selectedType = VehicleType.mobil;
    }
    _initialized = true;
  }

  @override
  void dispose() {
    _passengerController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  List<Vehicle> get _availableVehicles => dummyVehicles
      .where(
        (vehicle) =>
            vehicle.type == _selectedType &&
            vehicle.status == VehicleStatus.tersedia,
      )
      .toList();

  void _selectType(VehicleType type) {
    setState(() {
      _selectedType = type;
      if (_selectedVehicle?.type != type) {
        _selectedVehicle = null;
        LoanStateScope.of(context).clearSelectedVehicle();
      }
    });
  }

  void _selectVehicle(Vehicle? vehicle) {
    if (vehicle == null) {
      return;
    }
    setState(() {
      _selectedVehicle = vehicle;
      _errorMessage = null;
    });
    LoanStateScope.of(context).selectVehicle(vehicle);
  }

  Future<void> _pickDate({required bool borrow}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2026, 9, 21),
      firstDate: DateTime(2026),
      lastDate: DateTime(2030),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (borrow) {
        _borrowDate = _formatDate(picked);
      } else {
        _returnDate = _formatDate(picked);
      }
    });
  }

  Future<void> _pickTime({required bool borrow}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) {
      return;
    }
    final value =
        '${picked.hour.toString().padLeft(2, '0')}.${picked.minute.toString().padLeft(2, '0')}';
    setState(() {
      if (borrow) {
        _borrowTime = value;
      } else {
        _returnTime = value;
      }
    });
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _submit() {
    setState(() {
      _errorMessage = null;
    });

    if (_selectedVehicle == null) {
      setState(() {
        _errorMessage = 'Pilih kendaraan terlebih dahulu';
      });
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    LoanStateScope.of(context).submit(
      vehicle: _selectedVehicle!,
      borrowDate: _borrowDate,
      borrowTime: _borrowTime,
      returnDate: _returnDate,
      returnTime: _returnTime,
      destination: _destination,
      passengerCount: _passengerController.text,
      purpose: _purposeController.text,
    );

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const QueuePage()));
  }

  @override
  Widget build(BuildContext context) {
    LoanStateScope.of(context);

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
            'Ajukan Peminjaman',
            style: TextStyle(
              color: Color(0xFF20252B),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_selectedVehicle == null) ...[
                    _TypeSelector(
                      selectedType: _selectedType,
                      onChanged: _selectType,
                    ),
                    const SizedBox(height: 14),
                  ],
                  const _FormSectionTitle('Pilih Kendaraan'),
                  const SizedBox(height: 6),
                  if (_selectedVehicle == null)
                    DropdownButtonFormField<Vehicle>(
                      initialValue: null,
                      isExpanded: true,
                      hint: const Text('Pilih Kendaraan'),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                      decoration: _inputDecoration(),
                      items: _availableVehicles
                          .map(
                            (vehicle) => DropdownMenuItem<Vehicle>(
                              value: vehicle,
                              child: Text(
                                '${vehicle.name} • ${vehicle.code}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _selectVehicle,
                    )
                  else
                    _SelectedVehicleCard(vehicle: _selectedVehicle!),
                  if (_selectedVehicle == null) ...[
                    const SizedBox(height: 12),
                    _ReadOnlyField(
                      label: 'Kapasitas',
                      value: 'Pilih kendaraan terlebih dahulu',
                      icon: Icons.directions_car,
                      enabled: false,
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Color(0xFFD9534F),
                        fontSize: 9,
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  const _FormSectionTitle('Waktu Penggunaan'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeField(
                          label: 'Tanggal Pinjam',
                          value: _borrowDate,
                          icon: Icons.calendar_today_outlined,
                          onTap: () => _pickDate(borrow: true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateTimeField(
                          label: 'Waktu Pinjam',
                          value: _borrowTime,
                          icon: Icons.access_time_outlined,
                          onTap: () => _pickTime(borrow: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _DateTimeField(
                          label: 'Tanggal Kembali',
                          value: _returnDate,
                          icon: Icons.calendar_today_outlined,
                          onTap: () => _pickDate(borrow: false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _DateTimeField(
                          label: 'Waktu Kembali',
                          value: _returnTime,
                          icon: Icons.access_time_outlined,
                          onTap: () => _pickTime(borrow: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ReadOnlyField(
                    label: 'Lokasi Jempit  (Opsional)',
                    value: _pickupLocation,
                    icon: Icons.place_outlined,
                    onTap: () => setState(() {
                      _pickupLocation = 'Lokasi jempit dipilih';
                    }),
                  ),
                  const SizedBox(height: 12),
                  _ReadOnlyField(
                    label: 'Tujuan',
                    value: _destination,
                    icon: Icons.place_outlined,
                    onTap: () => setState(() {
                      _destination = 'Bala Desa Gkreeg';
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passengerController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      labelText: 'Jumlah Penumpang',
                      hintText: '4 orang',
                      prefixIcon: Icons.people_outline,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Jumlah penumpang wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _purposeController,
                    maxLines: 2,
                    decoration: _inputDecoration(
                      labelText: 'Keperluan',
                      hintText: 'Kegiatan monitoring lapangan',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Keperluan wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Ajukan Peminjaman'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeSelector extends StatelessWidget {
  const _TypeSelector({required this.selectedType, required this.onChanged});

  final VehicleType? selectedType;
  final ValueChanged<VehicleType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8EB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TypeButton(
              label: 'Mobil',
              selected: selectedType == VehicleType.mobil,
              onTap: () => onChanged(VehicleType.mobil),
            ),
          ),
          Expanded(
            child: _TypeButton(
              label: 'Motor',
              selected: selectedType == VehicleType.motor,
              onTap: () => onChanged(VehicleType.motor),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B75D1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF5C6670),
            fontSize: 10,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SelectedVehicleCard extends StatelessWidget {
  const _SelectedVehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFDCE1E6)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            height: 48,
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
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    color: Color(0xFF20252B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${vehicle.code}   ${vehicle.plateNumber}',
                  style: const TextStyle(color: Color(0xFF65707A), fontSize: 8),
                ),
                if (vehicle.capacity != null)
                  Text(
                    'Kapasitas ${vehicle.capacity} orang',
                    style: const TextStyle(
                      color: Color(0xFF65707A),
                      fontSize: 8,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(Icons.check_circle, color: Color(0xFF0B75D1), size: 18),
        ],
      ),
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF20252B),
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DateTimeField extends StatelessWidget {
  const _DateTimeField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: InputDecorator(
        decoration: _inputDecoration(labelText: label, prefixIcon: icon),
        child: Text(
          value,
          style: const TextStyle(color: Color(0xFF2E3742), fontSize: 9),
        ),
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        decoration: _inputDecoration(
          labelText: label,
          prefixIcon: icon,
          suffixIcon: Icons.chevron_right,
          enabled: enabled,
        ),
        child: Text(
          value,
          style: TextStyle(
            color: enabled ? const Color(0xFF2E3742) : const Color(0xFF9AA3AB),
            fontSize: 9,
          ),
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({
  String? labelText,
  String? hintText,
  IconData? prefixIcon,
  IconData? suffixIcon,
  bool enabled = true,
}) {
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    labelStyle: const TextStyle(
      color: Color(0xFF20252B),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    ),
    floatingLabelStyle: const TextStyle(color: Color(0xFF0B75D1), fontSize: 9),
    hintStyle: const TextStyle(color: Color(0xFF8A949E), fontSize: 9),
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 17, color: const Color(0xFF7D8791)),
    suffixIcon: suffixIcon == null
        ? null
        : Icon(suffixIcon, color: const Color(0xFF7D8791)),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    filled: true,
    fillColor: Colors.white,
    enabled: enabled,
    border: _border(),
    enabledBorder: _border(),
    disabledBorder: _border(color: const Color(0xFFE6E9EC)),
    focusedBorder: _border(color: const Color(0xFF0B75D1)),
  );
}

InputBorder _border({Color color = const Color(0xFFDCE1E6)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}
