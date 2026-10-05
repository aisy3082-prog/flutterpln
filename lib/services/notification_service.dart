import '../data/notification_data.dart';
import '../models/app_notification.dart';
import 'data_result.dart';

/// Kontrak sumber data notifikasi. Implementasi dummy sekarang; tinggal
/// tukar dengan pemanggilan HTTP/Supabase nanti.
abstract class NotificationService {
  Future<DataResult<List<AppNotification>>> loadNotifications();
}

class DummyNotificationService implements NotificationService {
  const DummyNotificationService();

  @override
  Future<DataResult<List<AppNotification>>> loadNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    if (dummyNotifications.isEmpty) {
      return const DataResult.empty();
    }
    return DataResult.success(dummyNotifications);
  }
}
