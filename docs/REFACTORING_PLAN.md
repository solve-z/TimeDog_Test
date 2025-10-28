# 폴더 구조 리팩토링 계획

## 📋 작업 개요

현재 `screen/main/tab/` 구조를 `features/` 기반 구조로 변경하여 각 도메인을 독립적으로 관리

## 🎯 목표 구조

```
lib/
├── main.dart
├── app.dart
│
├── common/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── utils/
│   │   ├── app_logger.dart
│   │   ├── category_utils.dart
│   │   └── date_utils.dart
│   ├── widgets/
│   │   ├── w_app_bar_actions.dart
│   │   ├── w_bottom_navigation.dart
│   │   ├── w_common_app_bar.dart
│   │   └── w_drawer_menu.dart
│   └── dialogs/
│       ├── d_add_todo.dart
│       ├── d_category_selection.dart
│       ├── d_number_picker.dart
│       ├── d_objective_edit.dart
│       ├── d_todo_required.dart
│       └── d_todo_selection.dart
│
├── features/
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
│   │   │   ├── w_timer_display.dart
│   │   │   └── w_todo_selector.dart
│   │   └── screens/
│   │       ├── s_timer.dart
│   │       └── s_pomodoro_setting.dart
│   │
│   ├── todo/
│   │   ├── models/
│   │   │   ├── vo_category.dart
│   │   │   ├── vo_daily_objective.dart
│   │   │   ├── vo_todo_category.dart
│   │   │   ├── vo_todo_item.dart
│   │   │   └── todo_items_dummy.dart
│   │   ├── providers/
│   │   │   ├── category_order_provider.dart
│   │   │   ├── category_provider.dart
│   │   │   ├── daily_objective_provider.dart
│   │   │   └── todo_provider.dart
│   │   ├── widgets/
│   │   │   ├── f_time_record.dart
│   │   │   ├── f_todo_current_view.dart
│   │   │   ├── f_todo_info_card.dart
│   │   │   ├── f_todo_list.dart
│   │   │   └── f_todo_view_header.dart
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
│   │   │   ├── w_simple_bar_chart.dart
│   │   │   └── w_tooltip_bubble.dart
│   │   └── screens/
│   │       └── s_statistics.dart
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

## 📝 단계별 작업 계획

### 1단계: 사전 준비 (Pre-work)

- [x] **1.1** 현재 git 상태 확인 및 커밋
- [x] **1.2** 테스트용 copy 파일 삭제
  - `w_heatmap_calendar copy.dart`
  - `statistics_data_service copy.dart`

### 2단계: features 폴더 생성

- [x] **2.1** `lib/features/` 폴더 생성
- [x] **2.2** 각 feature 하위 폴더 구조 생성
  ```bash
  features/timer/{models,providers,services,widgets,screens}
  features/todo/{models,providers,widgets,screens}
  features/statistics/{widgets,screens}
  features/music/{models,providers,services,dialogs}
  features/animation/{providers,dialogs}
  features/profile/screens
  ```

### 3단계: common 폴더 정리

- [x] **3.1** `common/constant/` → `common/constants/`로 리네임
- [x] **3.2** `common/dialog/` → `common/dialogs/`로 리네임
- [x] **3.3** `common/data/vo_music_option.dart` 이동 결정
  - music feature에서만 사용 → `features/music/models/`

### 4단계: Timer feature 이동

- [x] **4.1** Models 이동

  - `screen/main/tab/timer/vo/vo_timer.dart` → `features/timer/models/vo_timer.dart`

- [x] **4.2** Providers 이동

  - `timer_notifier.dart` → `features/timer/providers/`

- [x] **4.3** Services 이동

  - `timer_foreground_service.dart` → `features/timer/services/`
  - `timer_strategy.dart` → `features/timer/services/`

- [x] **4.4** Widgets 이동

  - `w_progress_indicator.dart` → `features/timer/widgets/`
  - `w_timer_controls.dart` → `features/timer/widgets/`
  - `w_timer_display.dart` → `features/timer/widgets/`
  - `w_todo_selector.dart` → `features/timer/widgets/`

- [x] **4.5** Screens 이동
  - `s_timer.dart` → `features/timer/screens/`
  - `screens/settings/s_pomodoro_setting.dart` → `features/timer/screens/`

### 5단계: Todo feature 이동

- [x] **5.1** Models 이동

  - `vo/vo_category.dart` → `features/todo/models/`
  - `vo/vo_daily_objective.dart` → `features/todo/models/`
  - `vo/vo_todo_category.dart` → `features/todo/models/`
  - `vo/vo_todo_item.dart` → `features/todo/models/`
  - `vo/todo_items_dummy.dart` → `features/todo/models/`

- [x] **5.2** Providers 이동

  - `category_order_provider.dart` → `features/todo/providers/`
  - `category_provider.dart` → `features/todo/providers/`
  - `daily_objective_provider.dart` → `features/todo/providers/`
  - `todo_provider.dart` → `features/todo/providers/`

- [x] **5.3** Widgets 이동

  - `f_time_record.dart` → `features/todo/widgets/`
  - `f_todo_current_view.dart` → `features/todo/widgets/`
  - `f_todo_info_card.dart` → `features/todo/widgets/`
  - `f_todo_list.dart` → `features/todo/widgets/`
  - `f_todo_view_header.dart` → `features/todo/widgets/`

- [x] **5.4** Screens 이동
  - `s_todo.dart` → `features/todo/screens/`
  - `s_todo_list.dart` → `features/todo/screens/`
  - `s_category_management.dart` → `features/todo/screens/`

### 6단계: Statistics feature 이동

- [x] **6.1** Services 이동

  - `services/statistics_data_service.dart` → `features/statistics/services/`

- [x] **6.2** Widgets 이동

  - `w_heatmap_calendar.dart` → `features/statistics/widgets/`
  - `w_simple_bar_chart.dart` → `features/statistics/widgets/`
  - `w_tooltip_bubble.dart` → `features/statistics/widgets/`

- [x] **6.3** Screens 이동
  - `s_statistics.dart` → `features/statistics/screens/`

### 7단계: Music feature 분리

- [x] **7.1** Models 이동

  - `common/data/vo_music_option.dart` → `features/music/models/`

- [x] **7.2** Providers 이동

  - `screen/main/tab/timer/music_provider.dart` → `features/music/providers/`

- [x] **7.3** Services 이동

  - `screen/main/tab/timer/music_player_service.dart` → `features/music/services/`

- [x] **7.4** Dialogs 이동

  - `screen/main/tab/timer/d_music_selection.dart` → `features/music/dialogs/`

- [x] **7.5** Screens 이동
  - `screens/settings/s_music_settings.dart` → `features/music/screens/`

### 8단계: Animation feature 분리

- [x] **8.1** Providers 이동

  - `screen/main/tab/timer/animation_provider.dart` → `features/animation/providers/`
  - `screen/main/tab/timer/video_controller_provider.dart` → `features/animation/providers/`

- [x] **8.2** Widgets 이동

  - `screen/main/tab/timer/f_character_animation.dart` → `features/animation/widgets/`

- [x] **8.3** Dialogs 이동

  - `screen/main/tab/timer/d_animation_selection.dart` → `features/animation/dialogs/`

- [x] **8.4** Screens 이동
  - `screens/settings/s_animation_settings.dart` → `features/animation/screens/`

### 9단계: Profile feature 이동

- [x] **9.1** Screens 이동
  - `screen/main/tab/profile/s_profile.dart` → `features/profile/screens/`

### 10단계: 전역 Services 이동

- [x] **10.1** Notification Service 이동
  - `screen/main/tab/timer/notification_service.dart` → `services/notification/notification_service.dart`

### 11단계: Main 화면 이동

- [x] **11.1** Main 화면 이동
  - `screen/main/s_main.dart` → `screens/s_main.dart`

### 12단계: Import 경로 수정

- [x] **12.1** 모든 파일의 import 문 검색 및 수정

  - 이전: `import 'package:timedog/screen/main/tab/timer/...`
  - 이후: `import 'package:timedog/features/timer/...`

- [x] **12.2** 자동 수정 도구 사용 (선택사항)
  - VSCode Find & Replace (Ctrl+Shift+H)
  - 정규식 사용하여 일괄 변경

### 13단계: 테스트 및 검증

- [x] **13.1** 앱 빌드 확인

  ```bash
  flutter clean
  flutter pub get
  flutter analyze
  ```

- [x] **13.2** 앱 실행 테스트

  ```bash
  flutter run
  ```

- [x] **13.3** 각 기능별 동작 확인
  - Timer 기능
  - Todo 기능
  - Statistics 기능
  - Music/Animation 설정
  - Profile 화면

### 14단계: 정리 (Cleanup)

- [x] **14.1** 빈 폴더 삭제

  - `screen/main/tab/timer/`
  - `screen/main/tab/todo/`
  - `screen/main/tab/statistics/`
  - `screen/main/tab/profile/`
  - `screen/main/tab/`
  - `screen/main/`
  - `screens/settings/`
  - `common/data/` (비어있다면)

- [ ] **14.2** Git 커밋
  ```bash
  git add .
  git commit -m "refactor: 폴더 구조를 features 기반으로 재구성"
  ```

## ⚠️ 주의사항

1. **Import 경로 문제**

   - 파일 이동 후 모든 import 경로가 자동으로 업데이트되지 않음
   - VSCode의 "Organize Imports" 기능 활용
   - `flutter analyze` 명령어로 오류 확인

2. **상대 경로 import**

   - 상대 경로 import가 있다면 절대 경로로 변경 권장
   - `import '../../../...` → `import 'package:timedog/...'`

3. **백업**

   - 작업 전 반드시 git commit 또는 백업
   - 문제 발생 시 롤백 가능하도록 준비

4. **점진적 작업**

   - 한 번에 모든 파일을 이동하지 말고 feature 단위로 이동
   - 각 feature 이동 후 앱이 정상 작동하는지 확인

5. **테스트 코드**
   - 테스트 파일이 있다면 함께 이동
   - `test/` 폴더 구조도 동일하게 맞추는 것 권장

## 🔧 유용한 명령어

### 파일 이동 (Git 이력 유지)

```bash
git mv old/path/file.dart new/path/file.dart
```

### 모든 import 오류 찾기

```bash
flutter analyze | grep "import"
```

### 특정 문자열을 포함한 파일 찾기

```bash
grep -r "screen/main/tab/timer" lib/
```

## 📚 참고 사항

- 이 작업은 순수 폴더 구조 변경이므로 비즈니스 로직은 수정하지 않음
- 파일 내용은 변경하지 않고 위치만 이동
- 작업 완료 후 `CLAUDE.md`의 "Folder Structure Rules" 참고하여 향후 파일 생성

## ✅ 완료 조건

- [x] 모든 파일이 새로운 구조에 맞게 이동됨
- [x] `flutter analyze` 오류 없음
- [x] 앱이 정상적으로 실행됨
- [x] 모든 기능이 정상 작동함
- [x] 기존 `screen/main/tab/` 폴더 구조 제거됨
- [x] Git 커밋 완료
