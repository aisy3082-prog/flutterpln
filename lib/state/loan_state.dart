import 'package:flutter/material.dart';

import '../data/history_data.dart';
import '../data/loan_request_data.dart';
import '../data/vehicle_data.dart';
import '../models/vehicle.dart';

enum LoanStatus { pengajuan, antrean, disetujui, dalamPerjalanan, selesai }

extension LoanStatusLabel on LoanStatus {
  String get label => switch (this) {
    LoanStatus.pengajuan => 'Pengajuan',
    LoanStatus.antrean => 'Antrean',
    LoanStatus.disetujui => 'Disetujui',
    LoanStatus.dalamPerjalanan => 'Dalam Perjalanan',
    LoanStatus.selesai => 'Selesai',
  };
}

class Driver {
  const Driver({required this.name, required this.phone});

  final String name;
  final String phone;
}

class LoanDraft {
  const LoanDraft({
    required this.borrowDate,
    required this.borrowTime,
    required this.returnDate,
    required this.returnTime,
    required this.destination,
    required this.passengerCount,
    required this.purpose,
  });

  final String borrowDate;
  final String borrowTime;
  final String returnDate;
  final String returnTime;
  final String destination;
  final String passengerCount;
  final String purpose;
}

class LoanState extends ChangeNotifier {
  LoanState()
    : currentVehicle = dummyVehicles.first,
      status = LoanStatus.dalamPerjalanan;

  static const driver = Driver(name: 'Budi Santoso', phone: '6281234567890');

  Vehicle currentVehicle;
  Vehicle? selectedVehicle;
  LoanStatus status;
  LoanDraft? draft;

  /// Jumlah pengajuan yang sedang diproses.
  int get activeSubmissions => dummySubmissions.length;

  /// Jumlah pengajuan yang menunggu persetujuan atasan.
  int get pendingApprovals => dummyPendingApprovals.length;

  /// True kalau ada perjalanan yang belum selesai.
  bool get hasActiveTrip => status != LoanStatus.selesai;

  /// Jumlah perjalanan yang sudah tercatat di riwayat.
  int get historyCount => dummyTripHistory.length;

  void beginNewRequest() {
    selectedVehicle = null;
    notifyListeners();
  }

  void clearSelectedVehicle() {
    selectedVehicle = null;
    notifyListeners();
  }

  void selectVehicle(Vehicle vehicle) {
    if (vehicle.status != VehicleStatus.tersedia) {
      return;
    }

    selectedVehicle = vehicle;
    notifyListeners();
  }

  void submit({
    required Vehicle vehicle,
    required String borrowDate,
    required String borrowTime,
    required String returnDate,
    required String returnTime,
    required String destination,
    required String passengerCount,
    required String purpose,
  }) {
    if (vehicle.status != VehicleStatus.tersedia) {
      return;
    }

    selectedVehicle = vehicle;
    currentVehicle = vehicle;
    status = LoanStatus.pengajuan;
    draft = LoanDraft(
      borrowDate: borrowDate,
      borrowTime: borrowTime,
      returnDate: returnDate,
      returnTime: returnTime,
      destination: destination,
      passengerCount: passengerCount,
      purpose: purpose,
    );
    notifyListeners();
  }

  void setStatus(LoanStatus nextStatus) {
    status = nextStatus;
    notifyListeners();
  }

  void completeTrip() {
    status = LoanStatus.selesai;
    notifyListeners();
  }
}

class LoanStateScope extends InheritedNotifier<LoanState> {
  const LoanStateScope({
    super.key,
    required LoanState state,
    required super.child,
  }) : super(notifier: state);

  static LoanState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LoanStateScope>();
    assert(scope != null, 'LoanStateScope tidak ditemukan pada context.');
    return scope!.notifier!;
  }
}
