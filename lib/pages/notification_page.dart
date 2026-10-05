import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_notification.dart';
import '../services/data_result.dart';
import '../services/notification_service.dart';
import '../state/notification_state.dart';
import '../utils/constants.dart';
import '../widgets/async_state_builder.dart';
import '../widgets/empty_notification_state.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_filter.dart';
import 'driver_confirm_page.dart';
import 'notification_detail_page.dart';
import 'trip_completed_page.dart';

/// Halaman Notifikasi: header, filter read/unread, dan daftar notifikasi.
class NotificationPage extends StatefulWidget {
  const NotificationPage({
    super.key,
    this.service = const DummyNotificationService(),
  });

  final NotificationService service;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<DataResult<List<AppNotification>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.loadNotifications();
  }

  void _reload() {
    setState(() {
      _future = widget.service.loadNotifications();
    });
  }

  void _openNotification(BuildContext context, AppNotification item) {
    // Membuka notifikasi otomatis menandainya sebagai sudah dibaca.
    final state = NotificationStateScope.maybeOf(context);
    state?.markAsRead(item.id);

    final Widget page = switch (item.type) {
      NotificationType.perjalananSelesai => TripCompletedPage(
        notification: item,
      ),
      NotificationType.pengajuanDisetujui => NotificationDetailPage(
        notification: item,
      ),
      NotificationType.driverDitugaskan => DriverConfirmPage(
        notification: item,
      ),
    };

    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final state = NotificationStateScope.of(context);
    final items = state.visibleNotifications;

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
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _NotificationHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  0,
                ),
                child: NotificationFilterBar(
                  selectedIndex: state.filter.index,
                  onChanged: (index) {
                    state.setFilter(NotificationFilter.values[index]);
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: FutureBuilder<DataResult<List<AppNotification>>>(
                  future: _future,
                  builder: (context, snapshot) {
                    final result =
                        snapshot.connectionState == ConnectionState.done
                        ? snapshot.data!
                        : const DataResult<List<AppNotification>>.loading();

                    return AsyncStateBuilder<List<AppNotification>>(
                      result: result,
                      onRetry: _reload,
                      emptyTitle: 'Tidak ada notifikasi',
                      emptyDescription:
                          'Belum ada informasi atau aktivitas terbaru.',
                      emptyIcon: Icons.notifications_none,
                      builder: (context, _) {
                        if (items.isEmpty) {
                          return const EmptyNotificationState();
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.xxl,
                            0,
                            AppSpacing.xxl,
                            AppSpacing.xxl,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: AppSpacing.xl),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return NotificationCard(
                              notification: item,
                              onTap: () => _openNotification(context, item),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationHeader extends StatelessWidget {
  const _NotificationHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        0,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.notifications_none,
              size: 18,
              color: AppColors.textStrong,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifikasi',
                  style: TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Informasi terbaru tentang peminjaman kendaraan dan aktivitas lainnya.',
                  style: TextStyle(
                    color: AppColors.textSubtle,
                    fontSize: 9,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
