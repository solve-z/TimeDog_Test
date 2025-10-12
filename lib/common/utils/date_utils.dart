/// 날짜 관련 유틸리티
/// 앱의 "하루"는 기본적으로 오전 6시부터 다음날 오전 6시까지로 정의됩니다.
/// 나중에 설정에서 사용자가 하루의 시작 시간을 변경할 수 있도록 준비되어 있습니다.
class AppDateUtils {
  // TODO: 나중에 설정값에서 가져오도록 변경
  // 현재는 하드코딩된 값 (오전 6시)
  static int dayStartHour = 6;

  /// 현재 시간 기준으로 "앱에서의 오늘" 날짜를 반환
  /// 예: 2025-01-15 02:00 (새벽 2시) → 2025-01-14 (전날)
  /// 예: 2025-01-15 07:00 (오전 7시) → 2025-01-15 (당일)
  static DateTime getAppToday() {
    final now = DateTime.now();
    return getAppDate(now);
  }

  /// 주어진 DateTime을 앱의 날짜 기준으로 변환
  /// - 시간이 dayStartHour 이전이면 전날로 간주
  /// - 시간이 dayStartHour 이후면 당일로 간주
  static DateTime getAppDate(DateTime dateTime) {
    if (dateTime.hour < dayStartHour) {
      // 새벽 시간대는 전날로 간주
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day - 1,
      );
    } else {
      // dayStartHour 이후는 당일로 간주
      return DateTime(
        dateTime.year,
        dateTime.month,
        dateTime.day,
      );
    }
  }

  /// 두 DateTime이 앱 기준으로 같은 날인지 확인
  static bool isSameAppDay(DateTime date1, DateTime date2) {
    final appDate1 = getAppDate(date1);
    final appDate2 = getAppDate(date2);

    return appDate1.year == appDate2.year &&
        appDate1.month == appDate2.month &&
        appDate1.day == appDate2.day;
  }

  /// 앱 기준 날짜의 시작 시간 반환
  /// 예: 2025-01-15 → 2025-01-15 06:00:00
  static DateTime getAppDayStart(DateTime appDate) {
    return DateTime(
      appDate.year,
      appDate.month,
      appDate.day,
      dayStartHour,
    );
  }

  /// 앱 기준 날짜의 종료 시간 반환 (다음날 dayStartHour 직전)
  /// 예: 2025-01-15 → 2025-01-16 05:59:59
  static DateTime getAppDayEnd(DateTime appDate) {
    return DateTime(
      appDate.year,
      appDate.month,
      appDate.day + 1,
      dayStartHour,
    ).subtract(const Duration(seconds: 1));
  }

  /// 주어진 DateTime이 특정 앱 날짜에 속하는지 확인
  /// (날짜의 dayStartHour ~ 다음날 dayStartHour 사이인지)
  static bool isInAppDay(DateTime dateTime, DateTime appDate) {
    final dayStart = getAppDayStart(appDate);
    final dayEnd = getAppDayEnd(appDate);

    return dateTime.isAfter(dayStart.subtract(const Duration(seconds: 1))) &&
        dateTime.isBefore(dayEnd.add(const Duration(seconds: 1)));
  }
}