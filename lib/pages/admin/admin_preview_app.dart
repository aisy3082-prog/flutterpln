import 'package:flutter/material.dart';

import '../../data/admin_vehicle_data.dart';
import '../../state/admin_auth_state.dart';
import '../../state/admin_loan_state.dart';
import '../../state/admin_notification_state.dart';
import '../../state/admin_vehicle_state.dart';
import 'admin_login_page.dart';

/// Entry point SEMENTARA untuk mencoba alur login Admin.
///
/// NANTI DIGANTI: file ini tidak dipakai alur user. Saat autentikasi Admin
/// sudah final, hapus file ini dan arahkan user ke `AdminLoginPage` dari
/// alur yang sebenarnya.
class AdminPreviewApp extends StatefulWidget {
  const AdminPreviewApp({super.key});

  @override
  State<AdminPreviewApp> createState() => _AdminPreviewAppState();
}

class _AdminPreviewAppState extends State<AdminPreviewApp> {
  late final AdminAuthState _adminAuthState = AdminAuthState();
  late final AdminLoanState _adminLoanState = AdminLoanState();
  late final AdminVehicleState _adminVehicleState = AdminVehicleState(
    vehicles: dummyAdminVehicles,
  );
  late final AdminNotificationState _adminNotificationState =
      AdminNotificationState();

  @override
  Widget build(BuildContext context) {
    return AdminNotificationStateScope(
      state: _adminNotificationState,
      child: AdminVehicleStateScope(
        state: _adminVehicleState,
        child: AdminLoanStateScope(
          state: _adminLoanState,
          child: AdminAuthStateScope(
            state: _adminAuthState,
            child: MaterialApp(
              title: 'PLN Move - Admin',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                scaffoldBackgroundColor: Colors.white,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color(0xFF0057A8),
                ),
              ),
              home: const AdminLoginPage(),
            ),
          ),
        ),
      ),
    );
  }
}
