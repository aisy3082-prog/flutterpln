enum HistoryEnergyType { bbm, listrik }

extension HistoryEnergyTypeLabel on HistoryEnergyType {
  String get label => switch (this) {
    HistoryEnergyType.bbm => 'BBM',
    HistoryEnergyType.listrik => 'Listrik',
  };
}

class TripHistory {
  const TripHistory({
    required this.date,
    required this.origin,
    required this.destination,
    required this.distanceKm,
    required this.duration,
  });

  final String date;
  final String origin;
  final String destination;
  final String distanceKm;
  final String duration;
}

/// Satu catatan pengisian energi. Field `name` berisi jenis BBM (mis.
/// Pertalite) atau nama sumber energi listrik, `unit` berisi L atau kWh,
/// dan `location` dipakai untuk titik pengisian listrik.
class EnergyHistory {
  const EnergyHistory({
    required this.type,
    required this.name,
    required this.date,
    required this.amount,
    required this.unit,
    required this.pricePerUnit,
    required this.totalCost,
    required this.distanceKm,
    this.location = '-',
  });

  final HistoryEnergyType type;
  final String name;
  final String date;
  final String amount;
  final String unit;
  final String pricePerUnit;
  final String totalCost;
  final String distanceKm;
  final String location;

  bool get isElectric => type == HistoryEnergyType.listrik;
}
