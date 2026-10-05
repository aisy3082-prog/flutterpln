import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'data/admin_vehicle_data.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'state/admin_auth_state.dart';
import 'state/admin_loan_state.dart';
import 'state/admin_notification_state.dart';
import 'state/admin_vehicle_state.dart';
import 'state/auth_state.dart';
import 'state/loan_state.dart';
import 'state/notification_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final LoanState _loanState = LoanState();
  late final NotificationState _notificationState = NotificationState();
  late final AuthState _authState = AuthState();

  /// Session Admin berdiri sendiri dari session user, supaya role Admin
  /// tidak pernah tercampur dengan user biasa.
  late final AdminAuthState _adminAuthState = AdminAuthState();

  /// Data peminjaman Admin (status dan driver) disimpan di satu tempat agar
  /// tetap sama di Beranda, Daftar, Detail, dan Konfirmasi Driver.
  late final AdminLoanState _adminLoanState = AdminLoanState();

  /// Data notifikasi Admin, dipakai halaman Notifikasi dan badge navbar.
  late final AdminNotificationState _adminNotificationState =
      AdminNotificationState();

  /// Data kendaraan Admin, dipakai Daftar Kendaraan dan form Tambah.
  late final AdminVehicleState _adminVehicleState =
      AdminVehicleState(vehicles: dummyAdminVehicles);

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
            child: AuthStateScope(
              state: _authState,
              child: LoanStateScope(
                state: _loanState,
                child: NotificationStateScope(
                  state: _notificationState,
                  child: MaterialApp(
                    title: 'PLN Move',
                    debugShowCheckedModeBanner: false,
                    theme: ThemeData(
                      useMaterial3: true,
                      scaffoldBackgroundColor: Colors.white,
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: const Color(0xFF0057A8),
                      ),
                    ),
                    home: const OnboardingFirstPage(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardingFirstPage extends StatelessWidget {
  const OnboardingFirstPage({super.key});

  static const Color brandBlue = Color(0xFF0057A8);

  void _openSecondOnboardingSlide(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const OnboardingSecondPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openSecondOnboardingSlide(context),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ============================================================
                // PADDING KIRI DAN KANAN
                // ============================================================
                final horizontalPadding = math.min(
                  24.0,
                  math.max(16.0, constraints.maxWidth * 0.08),
                );

                // ============================================================
                // UKURAN LOGO
                // Dibuat responsif mengikuti ukuran layar.
                // ============================================================
                final availableWidth = math.max(
                  0.0,
                  constraints.maxWidth - (horizontalPadding * 2),
                );

                final maxLogoByWidth = availableWidth * 0.96;

                final maxLogoByHeight = math.max(
                  0.0,
                  constraints.maxHeight - 100.0,
                );

                final logoSize = math.max(
                  1.0,
                  math.min(340.0, math.min(maxLogoByWidth, maxLogoByHeight)),
                );

                return CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          0,
                          horizontalPadding,
                          12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // ======================================================
                            // BAGIAN TENGAH
                            // ======================================================
                            Expanded(
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // LOGO
                                    _OnboardingLogo(size: logoSize),

                                    const SizedBox(height: 8),

                                    // NAMA APLIKASI
                                    const Text(
                                      'PLN Move',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: brandBlue,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ======================================================
                            // TEXT PALING BAWAH
                            // ======================================================
                            const Text(
                              'PT PLN (Persero)',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: brandBlue,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// ONBOARDING SLIDE KEDUA
// ==========================================================================

class OnboardingSecondPage extends StatelessWidget {
  const OnboardingSecondPage({super.key});

  static const Color _buttonBlue = Color(0xFF0B75D1);
  static const Color _buttonBorder = Color(0xFFE2E6EA);

  void _openLogin(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const LoginPage()));
  }

  void _openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RegisterPage(
          onLoginRequested: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = math.min(
                24.0,
                math.max(16.0, constraints.maxWidth * 0.08),
              );
              final availableWidth = math.max(
                0.0,
                constraints.maxWidth - (horizontalPadding * 2),
              );
              final maxLogoByWidth = availableWidth * 0.78;
              final maxLogoByHeight = math.max(
                0.0,
                constraints.maxHeight - 220.0,
              );
              final logoSize = math.max(
                1.0,
                math.min(260.0, math.min(maxLogoByWidth, maxLogoByHeight)),
              );

              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        0,
                        horizontalPadding,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                const Spacer(flex: 2),
                                _OnboardingLogo(size: logoSize),
                                const SizedBox(height: 24),
                                const Text(
                                  'PLN Move',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: OnboardingFirstPage.brandBlue,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                  ),
                                ),
                                const Spacer(flex: 3),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: ElevatedButton(
                                    onPressed: () => _openLogin(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _buttonBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: const Text('Login'),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 44,
                                  child: OutlinedButton(
                                    onPressed: () => _openRegister(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor:
                                          OnboardingFirstPage.brandBlue,
                                      side: const BorderSide(
                                        color: _buttonBorder,
                                      ),
                                      padding: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    child: const Text('Register'),
                                  ),
                                ),
                                const Spacer(flex: 1),
                              ],
                            ),
                          ),
                          const Text(
                            'PT PLN (Persero)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: OnboardingFirstPage.brandBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// LOGO
// ==========================================================================

class _OnboardingLogo extends StatelessWidget {
  const _OnboardingLogo({required this.size});

  final double size;

  // Ukuran area logo yang terlihat pada file PNG.
  //
  // File logo kamu memiliki ruang putih kosong di sekelilingnya,
  // sehingga bagian yang benar-benar terlihat hanya berada di
  // koordinat berikut.
  static const double assetMarkLeft = 123 / 500;
  static const double assetMarkRight = 385 / 500;
  static const double assetMarkTop = 131 / 500;
  static const double assetMarkBottom = 384 / 500;

  @override
  Widget build(BuildContext context) {
    final visibleWidth = size * (assetMarkRight - assetMarkLeft);

    final visibleHeight = size * (assetMarkBottom - assetMarkTop);

    return SizedBox(
      width: visibleWidth,
      height: visibleHeight,
      child: ClipRect(
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              left: -size * assetMarkLeft,
              top: -size * assetMarkTop,
              width: size,
              height: size,
              child: Image.asset(
                'assets/img/logo.png',
                width: size,
                height: size,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                // Kalau asset gagal terbaca, tampilkan ikon mobil sebagai
                // pengganti supaya tidak muncul kotak merah error.
                errorBuilder: (context, error, stackTrace) => Container(
                  width: visibleWidth,
                  height: visibleHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF3FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car,
                    color: OnboardingFirstPage.brandBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
