# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter project for "TimeDog" (타임독) - a timer/productivity app featuring a dog character named "김독". The app combines Pomodoro timer functionality with to-do list management, targeting students and self-improvement enthusiasts.

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

### 7. **기타 (나머지)**
- 파일명: 소문자, 숫자, `_` 조합 (공식 가이드 준수)
- 클래스명: PascalCase
- 예시:
  - `app_constants.dart` → `AppConstants`
  - `date_utils.dart` → `DateUtils`

## Dependencies

- `cupertino_icons` - iOS-style icons
- `flutter_lints` - Linting rules for code quality
- `flutter_svg` - SVG icon support
- Uses Material Design components
