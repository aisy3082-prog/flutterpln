import 'package:flutter/material.dart';

import '../models/vehicle.dart';
import '../state/loan_state.dart';
import 'fuel_input_page.dart';
import 'queue_page.dart';

class TripCompletionPage extends StatefulWidget {
  const TripCompletionPage({super.key, required this.vehicle});

  final Vehicle vehicle;

  @override
  State<TripCompletionPage> createState() => _TripCompletionPageState();
}

class _TripCompletionPageState extends State<TripCompletionPage> {
  static const Color _primaryBlue = Color(0xFF0B75D1);

  final _formKey = GlobalKey<FormState>();
  final _startKmController = TextEditingController(text: '45');
  final _endKmController = TextEditingController(text: '45');

  String _energyType = 'BBM';

  @override
  void dispose() {
    _startKmController.dispose();
    _endKmController.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final loanState = LoanStateScope.of(context);
    if (_energyType == 'BBM') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FuelInputPage(vehicle: widget.vehicle),
        ),
      );
      return;
    }

    loanState.completeTrip();
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
          'Penyelesaian Perjalanan',
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF35A744),
                  size: 54,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Perjalanan telah selesai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF20252B),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Silahkan input data kilometer BBM yang digunakan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF77818B), fontSize: 9),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Kilometer',
                    style: TextStyle(
                      color: Color(0xFF20252B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _CompletionField(
                        label: 'KM Awal',
                        controller: _startKmController,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _CompletionField(
                        label: 'KM Akhir',
                        controller: _endKmController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFD5E6FA)),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Jarak Perjalanan',
                        style: TextStyle(color: Color(0xFF65707A), fontSize: 8),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '45 KM',
                        style: TextStyle(
                          color: Color(0xFF0B75D1),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pengisian Energi Kendaraan',
                    style: TextStyle(
                      color: Color(0xFF20252B),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _EnergyButton(
                  label: 'BBM',
                  selected: _energyType == 'BBM',
                  onTap: () => setState(() => _energyType = 'BBM'),
                ),
                const SizedBox(height: 6),
                _EnergyButton(
                  label: 'Daya Listrik',
                  selected: _energyType == 'Daya Listrik',
                  onTap: () => setState(() => _energyType = 'Daya Listrik'),
                ),
                const SizedBox(height: 20),
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

class _CompletionField extends StatelessWidget {
  const _CompletionField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF65707A), fontSize: 9),
        floatingLabelStyle: const TextStyle(
          color: Color(0xFF0B75D1),
          fontSize: 9,
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        filled: true,
        fillColor: Colors.white,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(color: const Color(0xFF0B75D1)),
      ),
    );
  }
}

class _EnergyButton extends StatelessWidget {
  const _EnergyButton({
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
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFDFF1FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF0B75D1) : const Color(0xFFDCE1E6),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF0B75D1) : const Color(0xFF65707A),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

InputBorder _border({Color color = const Color(0xFFDCE1E6)}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: BorderSide(color: color),
  );
}
