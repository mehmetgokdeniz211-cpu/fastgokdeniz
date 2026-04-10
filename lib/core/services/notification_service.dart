// Dummy implementation for web compatibility
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    // No-op for web
  }

  Future<void> scheduleHourlyNotifications() async {
    // Not implemented for web
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Not implemented for web
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Not implemented for web
  }

  Future<String> getFCMToken() async {
    return '';
  }

  Future<void> enableNotifications() async {
    // Not implemented for web
  }

  Future<void> disableNotifications() async {
    // Not implemented for web
  }
}

void initializeTimezone() {
  // No-op for web
}
