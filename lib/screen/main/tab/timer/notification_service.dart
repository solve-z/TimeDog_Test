import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

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

  Future<bool> requestBatteryOptimizationExemption() async {
    try {
      if (!Platform.isAndroid) return true;

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      // Android 6.0 (API 23) 이상에서만 배터리 최적화 처리
      if (sdkVersion >= 23) {
        // 1. 기본 백그라운드 권한 확인
        if (!await FlutterBackground.hasPermissions) {
          print('백그라운드 권한이 없습니다.');
          return false;
        }

        // 2. 알림 권한 확인 및 요청
        if (sdkVersion >= 33) { // Android 13+
          final notificationStatus = await Permission.notification.status;
          if (!notificationStatus.isGranted) {
            final result = await Permission.notification.request();
            if (!result.isGranted) {
              print('알림 권한이 거부되었습니다.');
            }
          }
        }

        // 3. 정확한 알람 권한 확인 (Android 12+)
        if (sdkVersion >= 31) {
          final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
          if (!scheduleExactAlarmStatus.isGranted) {
            final result = await Permission.scheduleExactAlarm.request();
            if (!result.isGranted) {
              print('정확한 알람 권한이 거부되었습니다.');
            }
          }
        }

        // 4. 시스템 알람 권한 확인
        final systemAlertWindowStatus = await Permission.systemAlertWindow.status;
        if (!systemAlertWindowStatus.isGranted) {
          final result = await Permission.systemAlertWindow.request();
          if (!result.isGranted) {
            print('시스템 오버레이 권한이 거부되었습니다.');
          }
        }

        // 5. 배터리 최적화 예외 요청
        final ignoreBatteryOptimizationStatus = await Permission.ignoreBatteryOptimizations.status;
        if (!ignoreBatteryOptimizationStatus.isGranted) {
          final result = await Permission.ignoreBatteryOptimizations.request();
          if (!result.isGranted) {
            print('배터리 최적화 예외 권한이 거부되었습니다. 설정에서 수동으로 해제해주세요.');
          }
        }

        return await FlutterBackground.hasPermissions;
      }

      return true;
    } catch (e) {
      print('배터리 최적화 권한 확인 실패: $e');
      return false;
    }
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