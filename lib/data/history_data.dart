import '../models/history_models.dart';

const List<TripHistory> dummyTripHistory = [
  TripHistory(
    date: '21 Sep 2026',
    origin: 'Kantor PLN',
    destination: 'Balai Desa Girirejo',
    distanceKm: '45 km',
    duration: '1 jam 20 menit',
  ),
  TripHistory(
    date: '15 Sep 2026',
    origin: 'Kantor PLN',
    destination: 'Balai Desa Girirejo',
    distanceKm: '45 km',
    duration: '1 jam 20 menit',
  ),
  TripHistory(
    date: '08 Sep 2026',
    origin: 'Kantor PLN',
    destination: 'UPJS Magdalena',
    distanceKm: '32 km',
    duration: '55 menit',
  ),
];

const List<EnergyHistory> dummyBbmHistory = [
  EnergyHistory(
    type: HistoryEnergyType.bbm,
    name: 'Pertalite',
    date: '15 Sep 2026',
    amount: '30',
    unit: 'L',
    pricePerUnit: 'Rp 10.000',
    totalCost: 'Rp 300.000',
    distanceKm: '45.320 km',
  ),
  EnergyHistory(
    type: HistoryEnergyType.bbm,
    name: 'Pertamax',
    date: '08 Sep 2026',
    amount: '25',
    unit: 'L',
    pricePerUnit: 'Rp 12.500',
    totalCost: 'Rp 312.500',
    distanceKm: '32.100 km',
  ),
];

const List<EnergyHistory> dummyElectricHistory = [
  EnergyHistory(
    type: HistoryEnergyType.listrik,
    name: 'SPKLU Kantor PLN',
    date: '18 Sep 2026',
    amount: '42',
    unit: 'kWh',
    pricePerUnit: 'Rp 1.500',
    totalCost: 'Rp 63.000',
    distanceKm: '38.500 km',
    location: 'SPKLU Kantor PLN',
  ),
];
