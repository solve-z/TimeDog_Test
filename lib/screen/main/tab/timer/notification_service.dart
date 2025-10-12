import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';

/// 알림 권한 관리 서비스 및 완료 알림 처리
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isInitialized = false;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Android 알림 설정
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // 알림 클릭 시 처리 (필요시 구현)
      },
    );

    _isInitialized = true;
  }

  /// 배터리 최적화 예외 및 알림 권한 요청
  Future<bool> requestBatteryOptimizationExemption() async {
    try {
      if (!Platform.isAndroid) return true;

      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final sdkVersion = androidInfo.version.sdkInt;

      // Android 6.0 (API 23) 이상에서만 배터리 최적화 처리
      if (sdkVersion >= 23) {
        // 알림 권한 확인 및 요청 (Android 13+)
        if (sdkVersion >= 33) {
          final notificationStatus = await Permission.notification.status;
          if (!notificationStatus.isGranted) {
            final result = await Permission.notification.request();
            if (!result.isGranted) {
              print('알림 권한이 거부되었습니다.');
            }
          }
        }

        // 정확한 알람 권한 확인 (Android 12+)
        if (sdkVersion >= 31) {
          final scheduleExactAlarmStatus = await Permission.scheduleExactAlarm.status;
          if (!scheduleExactAlarmStatus.isGranted) {
            final result = await Permission.scheduleExactAlarm.request();
            if (!result.isGranted) {
              print('정확한 알람 권한이 거부되었습니다.');
            }
          }
        }

        // 배터리 최적화 예외 요청 (Doze 모드 대응)
        final ignoreBatteryOptimizationStatus = await Permission.ignoreBatteryOptimizations.status;
        if (!ignoreBatteryOptimizationStatus.isGranted) {
          final result = await Permission.ignoreBatteryOptimizations.request();
          if (!result.isGranted) {
            print('배터리 최적화 예외 권한이 거부되었습니다. 설정에서 수동으로 해제해주세요.');
            print('설정 > 앱 > TimeDog > 배터리 > 배터리 사용량 최적화에서 "최적화 안함"으로 설정해주세요.');
          }
        }

        return true;
      }

      return true;
    } catch (e) {
      print('배터리 최적화 권한 확인 실패: $e');
      return false;
    }
  }

  /// 완료 알림 표시 (팝업, 화면 꺼져있어도 표시)
  Future<void> showCompletionNotification({
    required String title,
    required String message,
  }) async {
    await initialize();

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'timer_completion', // Foreground와 다른 채널
      'Timer Completion Notifications',
      channelDescription: 'Notifications for timer completion events',
      importance: Importance.high, // 팝업 표시
      priority: Priority.high,
      playSound: false, // 소리 없음
      enableVibration: false, // 진동 없음
      showWhen: true,
      visibility: NotificationVisibility.public,
      fullScreenIntent: true, // 화면 꺼져있어도 표시
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      1, // Foreground Service와 다른 ID
      title,
      message,
      notificationDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}