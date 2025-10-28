# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter project for "TimeDog" (타임독) - a timer/productivity app featuring a dog character named "김독". The app combines Pomodoro timer functionality with to-do list management, targeting students and self-improvement enthusiasts.

## 디버그 log용

- print문 사용하지않고
- lib\common\utils\app_logger.dart 활용하기

## Development Commands

### Dependencies

- `flutter pub get` - Install dependencies
- `flutter pub upgrade` - Upgrade dependencies to latest versions

### Running the App

- `flutter run` - Run in debug mode
- `flutter run --release` - Run in release mode
- `flutter run -d chrome` - Run in web browser
- `flutter run -d windows` - Run on Windows desktop

### Code Quality

- `flutter analyze` - Run static analysis (configured via analysis_options.yaml)
- `flutter test` - Run all tests
- `flutter test test/widget_test.dart` - Run specific test file

### Building

- `flutter build apk` - Build Android APK
- `flutter build ios` - Build iOS app
- `flutter build web` - Build web version
- `flutter build windows` - Build Windows desktop app

## Architecture Overview

Currently a basic Flutter starter project with:

- `lib/main.dart` - Entry point with basic counter app
- Standard Flutter project structure with platform folders (android, ios, web, windows, linux, macos)
- Basic widget testing setup in `test/` directory

## Platform Support

- Android
- iOS
- Web (Chrome extension planned)
- Windows/Linux/macOS desktop

## Key Features (Planned)

- Pomodoro timer with focus/break cycles
- To-do list management with calendar integration
- Dog character animations based on timer state
- Statistics tracking
- Cross-platform notifications

## File Naming Conventions

### 1. **Widget**

- 파일명: `w_{name}.dart`
- 클래스명: `{Name}Widget`
- 예시:
  - `w_banner.dart` → `BannerWidget`
  - `w_custom_button.dart` → `CustomButtonWidget`

### 2. **Screen**

- 파일명: `s_{name}.dart`
- 클래스명: `{Name}Screen`
- 예시:
  - `s_home.dart` → `HomeScreen`
  - `s_login.dart` → `LoginScreen`

### 3. **Fragment**

- 파일명: `f_{name}.dart`
- 클래스명: `{Name}Fragment`
- 예시:
  - `f_invest.dart` → `InvestFragment`
  - `f_consume.dart` → `ConsumeFragment`

### 4. **Dialog**

- 파일명: `d_{name}.dart`
- 클래스명: `{Name}Dialog`
- 예시:
  - `d_logout_confirm.dart` → `LogoutConfirmDialog`
  - `d_bottom_menu.dart` → `BottomMenuDialog`

### 5. **Value Object (VO)**

- 파일명: `vo_{name}.dart`
- 클래스명: `{Name}Vo`
- 예시:
  - `vo_user.dart` → `UserVo`
  - `vo_banner.dart` → `BannerVo`

### 6. **Data Transfer Object (DTO)**

- 파일명: `dto_{name}.dart`
- 클래스명: `{Name}Dto`
- 예시:
  - `dto_user.dart` → `UserDto`
  - `dto_transaction.dart` → `TransactionDto`

### 7. **Dummy Data**

- 파일명: `{name}_dummy.dart`
- 내용: 테스트/개발용 더미 데이터
- 예시:
  - `todo_items_dummy.dart` → 할일 목록 더미 데이터
  - `user_data_dummy.dart` → 사용자 더미 데이터

### 8. **기타 (나머지)**

- 파일명: 소문자, 숫자, `_` 조합 (공식 가이드 준수)
- 클래스명: PascalCase
- 예시:
  - `app_constants.dart` → `AppConstants`
  - `date_utils.dart` → `DateUtils`

## Folder Structure Rules

### 기본 구조

```
lib/
├── main.dart                    # 앱 진입점
├── app.dart                     # 앱 루트 위젯
│
├── common/                      # 전역 공통 리소스
│   ├── constants/              # 상수 (app_constants.dart 등)
│   ├── utils/                  # 유틸리티 함수
│   ├── widgets/                # 공통 위젯 (w_*.dart)
│   ├── dialogs/                # 공통 다이얼로그 (d_*.dart)
│   └── models/                 # 전역에서 사용되는 공통 VO/DTO
│
├── features/                    # 기능별 도메인 폴더
│   ├── timer/
│   ├── todo/
│   ├── statistics/
│   ├── music/
│   ├── animation/
│   └── profile/
│
├── services/                    # 전역 인프라 서비스
│   └── notification/           # 카테고리별 폴더로 구조화
│       └── notification_service.dart
│
└── screens/                     # 앱 루트 레벨 화면
    └── s_main.dart             # 메인 네비게이션 화면
```

### Feature 폴더 내부 구조

각 feature는 독립적인 모듈처럼 구성:

```
features/{feature_name}/
├── models/                     # 해당 도메인의 VO, DTO
│   ├── vo_*.dart
│   └── *_dummy.dart           # 더미 데이터
│
├── providers/                  # 상태 관리 (Provider, Notifier 등)
│   └── *_provider.dart
│
├── services/                   # 해당 기능 전용 서비스
│   └── *_service.dart
│
├── widgets/                    # 해당 기능 전용 위젯
│   ├── w_*.dart
│   └── f_*.dart               # Fragment
│
├── dialogs/                    # 해당 기능 전용 다이얼로그
│   └── d_*.dart
│
└── screens/                    # 해당 기능의 화면들
    └── s_*.dart
```

### 파일 배치 규칙

1. **Screen (s_*.dart)**
   - 위치: `features/{feature}/screens/` (feature 전용 화면)
   - 위치: `screens/` (앱 루트 레벨 화면, 예: s_main.dart)
   - 전체 화면을 담당하는 페이지

2. **Widget (w_*.dart)**
   - 위치: `features/{feature}/widgets/` (기능 전용)
   - 위치: `common/widgets/` (여러 feature에서 재사용)
   - 재사용 가능한 UI 컴포넌트

3. **Fragment (f_*.dart)**
   - 위치: `features/{feature}/widgets/`
   - Screen의 일부분을 구성하는 큰 단위 위젯

4. **Dialog (d_*.dart)**
   - 위치: `features/{feature}/dialogs/` (기능 전용)
   - 위치: `common/dialogs/` (공통)
   - 모달, 다이얼로그, 바텀시트

5. **VO/DTO (vo_*.dart, dto_*.dart)**
   - 위치: `features/{feature}/models/` (해당 도메인 전용)
   - 위치: `common/models/` (여러 feature에서 공유)
   - 데이터 모델

6. **Provider/Notifier (*_provider.dart, *_notifier.dart)**
   - 위치: `features/{feature}/providers/`
   - 상태 관리 클래스

7. **Service (*_service.dart)**
   - 위치: `features/{feature}/services/` (기능 전용 비즈니스 로직)
   - 위치: `services/{category}/` (전역 인프라 서비스 - notification, api, database 등)
   - 비즈니스 로직, 외부 통신
   - 전역 서비스는 카테고리별 폴더로 구조화 (예: services/notification/)

8. **Utils (*_utils.dart)**
   - 위치: `common/utils/`
   - 순수 함수, 헬퍼 함수

9. **Constants (*_constants.dart)**
   - 위치: `common/constants/`
   - 앱 전역 상수

10. **Dummy Data (*_dummy.dart)**
    - 위치: `features/{feature}/models/`
    - 테스트/개발용 더미 데이터

### 배치 판단 기준

- **하나의 feature에서만 사용**: `features/{feature}/` 하위
- **여러 feature에서 재사용**: `common/` 하위
- **전역 인프라 서비스** (notification, API, DB, 로깅 등): `services/{category}/`
- **앱 루트 레벨 화면** (메인 네비게이션 등): `screens/`

### 실제 프로젝트 구조 예시

```
lib/
├── main.dart
├── app.dart
│
├── common/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── dialogs/
│   │   ├── d_add_todo.dart
│   │   ├── d_category_selection.dart
│   │   └── ...
│   ├── utils/
│   │   ├── app_logger.dart
│   │   ├── category_utils.dart
│   │   └── date_utils.dart
│   └── widgets/
│       ├── w_app_bar_actions.dart
│       ├── w_bottom_navigation.dart
│       └── ...
│
├── features/
│   ├── animation/
│   │   ├── providers/
│   │   │   ├── animation_provider.dart
│   │   │   └── video_controller_provider.dart
│   │   ├── widgets/
│   │   │   └── f_character_animation.dart
│   │   ├── dialogs/
│   │   │   └── d_animation_selection.dart
│   │   └── screens/
│   │       └── s_animation_settings.dart
│   │
│   ├── music/
│   │   ├── models/
│   │   │   └── vo_music_option.dart
│   │   ├── providers/
│   │   │   └── music_provider.dart
│   │   ├── services/
│   │   │   └── music_player_service.dart
│   │   ├── dialogs/
│   │   │   └── d_music_selection.dart
│   │   └── screens/
│   │       └── s_music_settings.dart
│   │
│   ├── timer/
│   │   ├── models/
│   │   │   └── vo_timer.dart
│   │   ├── providers/
│   │   │   └── timer_notifier.dart
│   │   ├── services/
│   │   │   ├── timer_foreground_service.dart
│   │   │   └── timer_strategy.dart
│   │   ├── widgets/
│   │   │   ├── w_progress_indicator.dart
│   │   │   ├── w_timer_controls.dart
│   │   │   └── ...
│   │   └── screens/
│   │       ├── s_timer.dart
│   │       └── s_pomodoro_setting.dart
│   │
│   ├── todo/
│   │   ├── models/
│   │   │   ├── vo_todo_item.dart
│   │   │   ├── vo_category.dart
│   │   │   └── ...
│   │   ├── providers/
│   │   │   ├── todo_provider.dart
│   │   │   └── ...
│   │   ├── widgets/
│   │   │   ├── f_todo_list.dart
│   │   │   └── ...
│   │   └── screens/
│   │       ├── s_todo.dart
│   │       ├── s_todo_list.dart
│   │       └── s_category_management.dart
│   │
│   ├── statistics/
│   │   ├── services/
│   │   │   └── statistics_data_service.dart
│   │   ├── widgets/
│   │   │   ├── w_heatmap_calendar.dart
│   │   │   └── ...
│   │   └── screens/
│   │       └── s_statistics.dart
│   │
│   └── profile/
│       └── screens/
│           └── s_profile.dart
│
├── services/
│   └── notification/
│       └── notification_service.dart
│
└── screens/
    └── s_main.dart
```

## Dependencies

- `cupertino_icons` - iOS-style icons
- `flutter_lints` - Linting rules for code quality
- `flutter_svg` - SVG icon support
- Uses Material Design components
