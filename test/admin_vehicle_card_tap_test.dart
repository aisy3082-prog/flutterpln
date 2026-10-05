import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_plnmobile/data/admin_vehicle_data.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_navigation.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_detail_page.dart';
import 'package:flutter_application_plnmobile/pages/admin/admin_vehicle_page.dart';
import 'package:flutter_application_plnmobile/state/admin_auth_state.dart';
import 'package:flutter_application_plnmobile/state/admin_loan_state.dart';
import 'package:flutter_application_plnmobile/state/admin_notification_state.dart';
import 'package:flutter_application_plnmobile/state/admin_vehicle_state.dart';

/// Shell Admin, supaya skenario sama dengan yang dipakai pengguna.
Widget _host(Widget child, AdminVehicleState state) {
  return AdminNotificationStateScope(
    state: AdminNotificationState(),
    child: AdminVehicleStateScope(
      state: state,
      child: AdminLoanStateScope(
        state: AdminLoanState(),
        child: AdminAuthStateScope(
          state: AdminAuthState()..signIn(),
          child: MaterialApp(home: child),
        ),
      ),
    ),
  );
}

Future<AdminVehicleState> bootShell(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  final state = AdminVehicleState(vehicles: dummyAdminVehicles);
  await tester.pumpWidget(_host(const AdminShellPage(), state));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('admin_bottom_nav_Kendaraan')));
  await tester.pumpAndSettle();
  return state;
}

/// Tekan card berdasarkan koordinat nyata (bukan lewat finder), supaya
/// area sentuh yang sebenarnya ikut teruji.
Future<void> tapCardAt(
  WidgetTester tester,
  int index, {
  String filter = 'Mobil',
}) async {
  final cards = find.byType(AdminVehicleCard);
  expect(cards.evaluate().length, greaterThan(index));
  final box = tester.getRect(cards.at(index));
  await tester.tapAt(box.center);
  await tester.pumpAndSettle();
}

/// Kode kendaraan pada card tertentu yang sedang terlihat.
String codeOfCard(WidgetTester tester, int index) {
  final texts = tester
      .widgetList<Text>(
        find.descendant(
          of: find.byType(AdminVehicleCard).at(index),
          matching: find.byType(Text),
        ),
      )
      .map((t) => t.data ?? '')
      .toList();
  return texts.firstWhere((d) => d.startsWith('KDM') || d.startsWith('KDN'));
}

void main() {
  group('Alur wajib: tekan card -> Detail -> kembali -> tekan card lain', () {
    testWidgets('1) kendaraan pertama, 2) kembali, 3) kendaraan kedua', (
      WidgetTester tester,
    ) async {
      final state = await bootShell(tester);
      addTearDown(state.dispose);

      expect(find.byType(AdminVehiclePage), findsOneWidget);

      // (1) Tekan kendaraan pertama.
      final firstCode = codeOfCard(tester, 0);
      await tapCardAt(tester, 0);

      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);
      expect(find.text('Detail Kendaraan'), findsOneWidget);
      expect(find.text('$firstCode    ${state.byCode(firstCode)!.plateNumber}'),
          findsOneWidget);
      expect(tester.takeException(), isNull);

      // (2) Kembali ke Daftar Kendaraan.
      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleDetailPage), findsNothing);
      expect(find.byType(AdminVehiclePage), findsOneWidget);

      // (3) Tekan kendaraan kedua -> harus data kendaraan kedua.
      final secondCode = codeOfCard(tester, 1);
      expect(secondCode, isNot(firstCode), reason: 'dua card berbeda');

      await tapCardAt(tester, 1);

      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);
      final secondVehicle = state.byCode(secondCode)!;
      expect(
        find.text('${secondVehicle.code}    ${secondVehicle.plateNumber}'),
        findsOneWidget,
      );
      // Data kendaraan pertama tidak boleh bocor ke sini.
      expect(
        find.text(
          '${state.byCode(firstCode)!.code}    '
          '${state.byCode(firstCode)!.plateNumber}',
        ),
        findsNothing,
      );
    });

    testWidgets('kendaraan pertama dan kedua pada filter Motor', (
      WidgetTester tester,
    ) async {
      final state = await bootShell(tester);
      addTearDown(state.dispose);

      await tester.tap(find.widgetWithText(InkWell, 'Motor'));
      await tester.pumpAndSettle();
      expect(find.byType(AdminVehicleCard), findsNWidgets(4));

      final firstCode = codeOfCard(tester, 0);
      expect(firstCode, startsWith('KDM'));
      await tapCardAt(tester, 0);
      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);
      expect(find.text('Lifan'), findsWidgets);

      await tester.tap(find.byTooltip('Kembali'));
      await tester.pumpAndSettle();

      final secondCode = codeOfCard(tester, 1);
      await tapCardAt(tester, 1);
      expect(find.byType(AdminVehicleDetailPage), findsOneWidget);
      expect(
        find.text('$secondCode    ${state.byCode(secondCode)!.plateNumber}'),
        findsOneWidget,
      );
      expect(find.text('$firstCode    ${state.byCode(firstCode)!.plateNumber}'),
          findsNothing);
    });
  });

  group('Setiap card dapat ditekan', () {
    for (final filter in const ['Mobil', 'Motor']) {
      testWidgets('semua 4 card pada filter $filter bisa ditekan', (
        WidgetTester tester,
      ) async {
        final state = await bootShell(tester);
        addTearDown(state.dispose);

        await tester.tap(find.widgetWithText(InkWell, filter));
        await tester.pumpAndSettle();

        final count = find.byType(AdminVehicleCard).evaluate().length;
        expect(count, 4);

        for (var i = 0; i < count; i++) {
          final code = codeOfCard(tester, i);
          await tapCardAt(tester, i);

          expect(
            find.byType(AdminVehicleDetailPage),
            findsOneWidget,
            reason: 'card $i ($code) harus terbuka',
          );
          expect(
            find.text('$code    ${state.byCode(code)!.plateNumber}'),
            findsOneWidget,
            reason: 'card $i harus menampilkan data itself',
          );

          await tester.tap(find.byTooltip('Kembali'));
          await tester.pumpAndSettle();
          expect(find.byType(AdminVehiclePage), findsOneWidget);
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('seluruh status tetap bisa dibuka', (WidgetTester tester) async {
      final state = await bootShell(tester);
      addTearDown(state.dispose);

      // Buka Mobil dan Motor supaya semua status terperiksa.
      for (final filter in const ['Mobil', 'Motor']) {
        await tester.tap(find.widgetWithText(InkWell, filter));
        await tester.pumpAndSettle();

        for (final status in ['Tersedia', 'Digunakan', 'Perawatan']) {
          expect(
            find.text(status),
            findsWidgets,
            reason: 'status $status harus ada di $filter',
          );
        }
      }
    });
  });

  group('Area tap card', () {
    testWidgets('card punya onTap dan area sentuh penuh', (
      WidgetTester tester,
    ) async {
      final state = await bootShell(tester);
      addTearDown(state.dispose);

      final card = find.byType(AdminVehicleCard).first;
      final widget = tester.widget<AdminVehicleCard>(card);
      expect(widget.onTap, isNotNull, reason: 'card harus punya onTap');

      // Tapping di beberapa titik dalam card semuanya membuka detail.
      final box = tester.getRect(card);
      for (final point in [
        box.topLeft + const Offset(6, 6),
        box.center,
        box.bottomRight - const Offset(6, 6),
      ]) {
        await tester.tapAt(point);
        await tester.pumpAndSettle();
        expect(
          find.byType(AdminVehicleDetailPage),
          findsOneWidget,
          reason: 'titik $point harus membuka detail',
        );
        await tester.tap(find.byTooltip('Kembali'));
        await tester.pumpAndSettle();
      }
    });
  });

  group('Responsive', () {
    testWidgets('card dapat ditekan di berbagai ukuran layar', (
      WidgetTester tester,
    ) async {
      for (final size in const [
        Size(320, 480),
        Size(360, 640),
        Size(393, 852),
      ]) {
        await tester.binding.setSurfaceSize(size);
        final state = await bootShell(tester);

        for (var i = 0; i < 2; i++) {
          final cards = find.byType(AdminVehicleCard);
          if (i >= cards.evaluate().length) {
            break;
          }
          final box = tester.getRect(cards.at(i));
          if (box.bottom > size.height) {
            await tester.drag(find.byType(ListView), const Offset(0, -200));
            await tester.pumpAndSettle();
          }
          await tapCardAt(tester, i);
          expect(
            find.byType(AdminVehicleDetailPage),
            findsOneWidget,
            reason: 'card $i harus terbuka di $size',
          );
          await tester.tap(find.byTooltip('Kembali'));
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull, reason: 'tanpa error di $size');
        state.dispose();
      }
      await tester.binding.setSurfaceSize(null);
    });
  });
}