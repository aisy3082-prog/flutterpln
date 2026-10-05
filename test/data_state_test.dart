import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/models/history_models.dart';
import 'package:flutter_application_plnmobile/models/loan_request.dart';
import 'package:flutter_application_plnmobile/pages/approval_status_page.dart';
import 'package:flutter_application_plnmobile/pages/history_page.dart';
import 'package:flutter_application_plnmobile/pages/submission_status_page.dart';
import 'package:flutter_application_plnmobile/services/history_service.dart';
import 'package:flutter_application_plnmobile/state/loan_state.dart';
import 'package:flutter_application_plnmobile/widgets/state_views.dart';

class _FakeHistoryService implements HistoryService {
  _FakeHistoryService(this.trips, this.energy);

  final List<TripHistory> trips;
  final List<EnergyHistory> energy;

  @override
  Future<DataResult<List<TripHistory>>> loadTrips() async {
    if (trips.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(trips);
  }

  @override
  Future<DataResult<List<EnergyHistory>>> loadEnergy({
    required HistoryEnergyType type,
  }) async {
    if (energy.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(energy);
  }
}

/// Service yang tidak selesai sampai [_pending] di-complete, supaya state
/// loading bisa diamati.
class _PendingHistoryService implements HistoryService {
  final Completer<void> _pending = Completer<void>();

  void release() => _pending.complete();

  @override
  Future<DataResult<List<TripHistory>>> loadTrips() async {
    await _pending.future;
    return DataResult.success(const [_sampleTrip]);
  }

  @override
  Future<DataResult<List<EnergyHistory>>> loadEnergy({
    required HistoryEnergyType type,
  }) async {
    await _pending.future;
    return DataResult.success(const [_sampleEnergy]);
  }
}

class _PendingLoanRequestService implements LoanRequestService {
  final Completer<void> _pending = Completer<void>();

  void release() => _pending.complete();

  @override
  Future<DataResult<List<LoanRequest>>> loadPendingApprovals() async {
    await _pending.future;
    return DataResult.success(const [_sampleRequest]);
  }

  @override
  Future<DataResult<List<LoanRequest>>> loadSubmissions() async {
    await _pending.future;
    return DataResult.success(const [_sampleRequest]);
  }
}

class _ErrorHistoryService implements HistoryService {
  @override
  Future<DataResult<List<TripHistory>>> loadTrips() async =>
      const DataResult.error('Gagal memuat riwayat perjalanan.');

  @override
  Future<DataResult<List<EnergyHistory>>> loadEnergy({
    required HistoryEnergyType type,
  }) async => const DataResult.error('Gagal memuat riwayat energi.');
}

class _FakeLoanRequestService implements LoanRequestService {
  _FakeLoanRequestService(this.requests);

  final List<LoanRequest> requests;

  @override
  Future<DataResult<List<LoanRequest>>> loadPendingApprovals() async {
    if (requests.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(requests);
  }

  @override
  Future<DataResult<List<LoanRequest>>> loadSubmissions() async {
    if (requests.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(requests);
  }
}

const _sampleRequest = LoanRequest(
  number: 'PNG-2026-0001',
  vehicleName: 'Toyota Innova',
  vehicleCode: 'KDN-001',
  plateNumber: 'AB 123 XX',
  purpose: 'Pemeliharaan Gardu Induk',
  destination: 'UPJS Magdalena',
  submittedAt: '21 Sep 2026',
  borrowDate: '22 Sep 2026',
  returnDate: '22 Sep 2026',
  status: LoanRequestStatus.menungguPersetujuan,
);

const _sampleTrip = TripHistory(
  date: '21 Sep 2026',
  origin: 'Kantor PLN',
  destination: 'Balai Desa Girirejo',
  distanceKm: '45 km',
  duration: '1 jam 20 menit',
);

const _sampleEnergy = EnergyHistory(
  type: HistoryEnergyType.bbm,
  name: 'Pertalite',
  date: '21 Sep 2026',
  amount: '30',
  unit: 'L',
  pricePerUnit: 'Rp 10.000',
  totalCost: 'Rp 300.000',
  distanceKm: '45.320 km',
);

Widget _host(Widget child, {LoanState? state}) {
  return LoanStateScope(
    state: state ?? LoanState(),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('Riwayat Kendaraan', () {
    testWidgets('shows a loading state before data arrives', (
      WidgetTester tester,
    ) async {
      final service = _PendingHistoryService();
      await tester.pumpWidget(_host(HistoryPage(service: service)));

      // Future belum selesai, jadi yang tampil adalah loading indicator.
      await tester.pump();
      expect(find.byType(LoadingStateView), findsOneWidget);

      service.release();
      await tester.pumpAndSettle();
      expect(find.byType(LoadingStateView), findsNothing);
      expect(find.textContaining('Balai Desa Girirejo'), findsOneWidget);
    });

    testWidgets('shows an empty state when there is no trip history', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(HistoryPage(service: _FakeHistoryService(const [], const []))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada riwayat perjalanan'), findsOneWidget);
    });

    testWidgets('shows an error state with a retry action', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(HistoryPage(service: _ErrorHistoryService())),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat riwayat perjalanan.'), findsOneWidget);
      expect(find.text('Coba Lagi'), findsOneWidget);
    });

    testWidgets('lists trips and energy records when data exists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          HistoryPage(
            service: _FakeHistoryService(
              const [_sampleTrip],
              const [_sampleEnergy],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Balai Desa Girirejo'), findsOneWidget);
      expect(find.text('45 km - 1 jam 20 menit'), findsOneWidget);

      await tester.tap(find.text('Energi'));
      await tester.pumpAndSettle();
      expect(find.text('Pertalite'), findsOneWidget);
      expect(find.text('Rp 300.000'), findsOneWidget);
    });

    testWidgets('electric vehicle opens the Listrik energy tab by default', (
      WidgetTester tester,
    ) async {
      final state = LoanState();
      state.currentVehicle = LoanState().currentVehicle.copyWithElectric();

      await tester.pumpWidget(
        _host(
          HistoryPage(
            service: _FakeHistoryService(const [], const [_sampleEnergy]),
          ),
          state: state,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Energi'));
      await tester.pumpAndSettle();
      expect(find.text('Jumlah Liter'), findsOneWidget);
    });
  });

  group('Menunggu Persetujuan dan Pengajuan', () {
    testWidgets('approval page shows loading then the request card', (
      WidgetTester tester,
    ) async {
      final service = _PendingLoanRequestService();
      await tester.pumpWidget(
        MaterialApp(home: ApprovalStatusPage(service: service)),
      );

      await tester.pump();
      expect(find.byType(LoadingStateView), findsOneWidget);

      service.release();
      await tester.pumpAndSettle();
      expect(find.text('PNG-2026-0001'), findsOneWidget);
      expect(find.text('Menunggu Persetujuan'), findsOneWidget);
      expect(find.text('Pemeliharaan Gardu Induk'), findsOneWidget);
      expect(
        find.text('Pengajuan sedang menunggu persetujuan atasan.'),
        findsOneWidget,
      );
    });

    testWidgets('approval page keeps the empty state when nothing is pending', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ApprovalStatusPage(service: _FakeLoanRequestService(const [])),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada persetujuan'), findsOneWidget);
    });

    testWidgets('submission page lists submissions when data exists', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SubmissionStatusPage(
            service: _FakeLoanRequestService(const [_sampleRequest]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PNG-2026-0001'), findsOneWidget);
      expect(find.text('UPJS Magdalena'), findsOneWidget);
    });

    testWidgets('submission page shows the empty state without data', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SubmissionStatusPage(
            service: _FakeLoanRequestService(const []),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tidak ada pengajuan'), findsOneWidget);
    });
  });
}
