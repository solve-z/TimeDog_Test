import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background/flutter_background.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await _requestPermissions();
    await _initializeBackgroundExecution();

    _isInitialized = true;
  }

  Future<void> _requestPermissions() async {
    final plugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await plugin?.requestNotificationsPermission();
  }

  Future<void> _initializeBackgroundExecution() async {
    const androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: "TimeDog 타이머",
      notificationText: "타이머가 백그라운드에서 실행 중입니다",
      notificationImportance: AndroidNotificationImportance.normal,
      enableWifiLock: true,
    );

    await FlutterBackground.initialize(androidConfig: androidConfig);
  }

  Future<void> showTimerRunningNotification({
    required String timeRemaining,
    required String phase,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'timer_running',
      'Timer Running',
      channelDescription: 'Shows timer progress while running',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      showWhen: false,
      enableVibration: false,
      playSound: false,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      1,
      'TimeDog - $phase',
      '남은 시간: $timeRemaining',
      details,
    );
  }

  Future<void> showTimerCompleteNotification({
    required String title,
    required String message,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'timer_complete',
      'Timer Complete',
      channelDescription: 'Notifications when timer completes',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      message,
      details,
    );
  }

  Future<void> cancelRunningNotification() async {
    await _notifications.cancel(1);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<bool> enableBackgroundExecution() async {
    await initialize(); // 초기화 보장

    if (!await FlutterBackground.hasPermissions) {
      return false;
    }
    return await FlutterBackground.enableBackgroundExecution();
  }

  Future<bool> disableBackgroundExecution() async {
    if (FlutterBackground.isBackgroundExecutionEnabled) {
      return await FlutterBackground.disableBackgroundExecution();
    }
    return true;
  }

  bool get isBackgroundExecutionEnabled => FlutterBackground.isBackgroundExecutionEnabled;
}