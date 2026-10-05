import 'package:flutter/material.dart';

String _formatPrice(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

class FuelTypeSelectionPage extends StatelessWidget {
  const FuelTypeSelectionPage({super.key, required this.selectedFuel});

  final String selectedFuel;

  static const Map<String, int> prices = {
    'Pertalite': 10000,
    'Pertamax': 16500,
    'Pertamax Turbo': 17600,
    'Dexlite': 15300,
    'Solar': 6800,
  };

  @override
  Widget build(BuildContext context) {
    final selectedPrice = prices[selectedFuel] ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF0B75D1),
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20, color: Colors.white),
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Pilih Jenis BBM',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFDCE1E6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Pilih Jenis BBM',
                    style: TextStyle(
                      color: Color(0xFF20252B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...prices.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _FuelOption(
                        label: entry.key,
                        price: entry.value,
                        selected: entry.key == selectedFuel,
                        onTap: () => Navigator.of(context).pop(entry.key),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$selectedFuel\nJumlah/Liter: ${_formatNumber(20)} L\nHarga Per Liter: Rp ${_formatPrice(selectedPrice)}\nTotal Biaya: Rp ${_formatPrice(selectedPrice * 20)}',
                    style: const TextStyle(
                      color: Color(0xFF65707A),
                      fontSize: 8,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int value) => value.toString();
}

class _FuelOption extends StatelessWidget {
  const _FuelOption({
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF3FF) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? const Color(0xFF0B75D1) : const Color(0xFFDCE1E6),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 18,
              color: selected
                  ? const Color(0xFF0B75D1)
                  : const Color(0xFF7D8791),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF20252B),
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rp ${_formatPrice(price)} / L',
                    style: const TextStyle(
                      color: Color(0xFF77818B),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 16,
              color: selected
                  ? const Color(0xFF0B75D1)
                  : const Color(0xFF7D8791),
            ),
          ],
        ),
      ),
    );
  }
}
