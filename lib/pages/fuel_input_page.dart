import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../state/loan_state.dart';
import 'fuel_type_selection_page.dart';
import 'queue_page.dart';

class FuelInputPage extends StatefulWidget {
  const FuelInputPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<FuelInputPage> createState() => _FuelInputPageState();
}

class _FuelInputPageState extends State<FuelInputPage> {
  static const Color _primaryBlue = Color(0xFF0B75D1);
  static const Color _border = Color(0xFFDCE1E6);

  static const Map<String, int> _fuelPrices = {
    'Pertalite': 10000,
    'Pertamax': 16500,
    'Pertamax Turbo': 17600,
    'Dexlite': 15300,
    'Solar': 6800,
  };

  final _formKey = GlobalKey<FormState>();
  final _litersController = TextEditingController(text: '20');
  late final TextEditingController _priceController;
  late final TextEditingController _totalController;

  String _fuelType = 'Pertalite';

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '10000');
    _totalController = TextEditingController(text: '200.000');
    _litersController.addListener(_updateTotal);
  }

  @override
  void dispose() {
    _litersController
      ..removeListener(_updateTotal)
      ..dispose();
    _priceController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    final liters = int.tryParse(_litersController.text) ?? 0;
    final price = int.tryParse(_priceController.text) ?? 0;
    _totalController.text = _formatRupiah(liters * price);
  }

  String _formatRupiah(int value) {
    final digits = value.toString();
    final buffer = StringBuffer();
    for (var index = 0; index < digits.length; index++) {
      if (index > 0 && (digits.length - index) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(digits[index]);
    }
    return 'Rp ${buffer.toString()}';
  }

  Future<void> _chooseFuelType() async {
    final selected = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => FuelTypeSelectionPage(selectedFuel: _fuelType),
      ),
    );
    if (selected == null || !mounted) {
      return;
    }
    setState(() {
      _fuelType = selected;
      _priceController.text = _fuelPrices[selected].toString();
      _updateTotal();
    });
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    LoanStateScope.of(context).completeTrip();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const QueuePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          color: Colors.white,
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Input BBM',
          style: TextStyle(
            color: Colors.white,
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
                _FuelVehicleCard(vehicle: widget.vehicle),
                const SizedBox(height: 14),
                const _FuelLabel('Tanggal Pengisian'),
                const SizedBox(height: 6),
                const _ReadOnlyFuelField(
                  value: '21 Sep 2026',
                  icon: Icons.calendar_today_outlined,
                ),
                const SizedBox(height: 12),
                const _FuelLabel('Lokasi Pengisian'),
                const SizedBox(height: 6),
                const _ReadOnlyFuelField(
                  value: 'UPJS Magdalena',
                  icon: Icons.place_outlined,
                ),
                const SizedBox(height: 12),
                const _FuelLabel('Jenis BBM'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: _chooseFuelType,
                  child: _ReadOnlyFuelField(
                    value:
                        '$_fuelType (${_formatRupiah(_fuelPrices[_fuelType]!)} / L)',
                    icon: Icons.local_gas_station_outlined,
                    showChevron: true,
                  ),
                ),
                const SizedBox(height: 12),
                const _FuelLabel('Jumlah Liter'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _litersController,
                  keyboardType: TextInputType.number,
                  decoration: _decoration(suffixText: 'L'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Jumlah liter wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FuelLabel('Harga Per Liter'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.number,
                            decoration: _decoration(prefixText: 'Rp '),
                            onChanged: (_) => _updateTotal(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _FuelLabel('Total Biaya'),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _totalController,
                            readOnly: true,
                            decoration: _decoration(prefixText: 'Rp '),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const _FuelLabel('Upload Bukti'),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Upload bukti belum tersedia.'),
                      ),
                    );
                  },
                  child: Container(
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _border),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 18,
                          color: Color(0xFF7D8791),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Upload bukti',
                          style: TextStyle(
                            color: Color(0xFF7D8791),
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: _save,
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
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FuelVehicleCard extends StatelessWidget {
  const _FuelVehicleCard({required this.vehicle});

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
            width: 74,
            height: 50,
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
                  '${vehicle.name} - ${vehicle.code}',
                  style: const TextStyle(
                    color: Color(0xFF20252B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  vehicle.plateNumber,
                  style: const TextStyle(color: Color(0xFF65707A), fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FuelLabel extends StatelessWidget {
  const _FuelLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF20252B),
        fontSize: 9,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReadOnlyFuelField extends StatelessWidget {
  const _ReadOnlyFuelField({
    required this.value,
    required this.icon,
    this.showChevron = false,
  });

  final String value;
  final IconData icon;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: _decoration(prefixIcon: icon),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9),
            ),
          ),
          if (showChevron)
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF7D8791)),
        ],
      ),
    );
  }
}

InputDecoration _decoration({
  IconData? prefixIcon,
  String? prefixText,
  String? suffixText,
}) {
  return InputDecoration(
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 17, color: const Color(0xFF7D8791)),
    prefixText: prefixText,
    suffixText: suffixText,
    prefixStyle: const TextStyle(color: Color(0xFF65707A), fontSize: 9),
    suffixStyle: const TextStyle(color: Color(0xFF65707A), fontSize: 9),
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
    filled: true,
    fillColor: Colors.white,
    border: _border(),
    enabledBorder: _border(),
    focusedBorder: _border(color: const Color(0xFF0B75D1)),
  );
}

InputBorder _border({Color color = const Color(0xFFDCE1E6)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}
