import '../data/history_data.dart';
import '../data/loan_request_data.dart';
import '../models/history_models.dart';
import '../models/loan_request.dart';
import 'data_result.dart';

export 'data_result.dart';

/// Kontrak sumber data. Implementasi dummy sekarang, tinggal tukar
/// implementasi ini ketika backend tersedia.
abstract class HistoryService {
  Future<DataResult<List<TripHistory>>> loadTrips();

  Future<DataResult<List<EnergyHistory>>> loadEnergy({
    required HistoryEnergyType type,
  });
}

class DummyHistoryService implements HistoryService {
  const DummyHistoryService();

  @override
  Future<DataResult<List<TripHistory>>> loadTrips() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (dummyTripHistory.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(dummyTripHistory);
  }

  @override
  Future<DataResult<List<EnergyHistory>>> loadEnergy({
    required HistoryEnergyType type,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final records = switch (type) {
      HistoryEnergyType.bbm => dummyBbmHistory,
      HistoryEnergyType.listrik => dummyElectricHistory,
    };
    if (records.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(records);
  }
}

abstract class LoanRequestService {
  Future<DataResult<List<LoanRequest>>> loadPendingApprovals();

  Future<DataResult<List<LoanRequest>>> loadSubmissions();
}

class DummyLoanRequestService implements LoanRequestService {
  const DummyLoanRequestService();

  @override
  Future<DataResult<List<LoanRequest>>> loadPendingApprovals() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (dummyPendingApprovals.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(dummyPendingApprovals);
  }

  @override
  Future<DataResult<List<LoanRequest>>> loadSubmissions() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (dummySubmissions.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(dummySubmissions);
  }
}
