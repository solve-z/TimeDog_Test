# 인증 기능 구현 계획 (Implementation Plan)

## 개요

auth_spec.md를 기반으로 한 단계별 구현 계획 및 Git 커밋 전략

---

## Phase 1: 환경 설정 및 의존성 추가

### 1-1. Supabase 프로젝트 생성 및 설정 ✅
**작업 내용:**
- Supabase 프로젝트 생성
- Google OAuth Provider 설정
- Database profiles 테이블 생성 및 RLS 정책 설정

**완료 상태:** ✅ 완료 (2025-01-30)
- Supabase 프로젝트: https://slvkibrntswmagwpxuyt.supabase.co
- Google OAuth 설정 완료
- profiles 테이블 및 RLS 정책 생성 완료

**커밋 메시지:**
```
docs: Supabase 프로젝트 설정 및 DB 스키마 추가

- profiles 테이블 생성 (nickname, avatar_url 등)
- RLS 정책 설정
- Google OAuth Provider 설정 완료
```

### 1-2. Flutter 의존성 추가 ✅
**작업 내용:**
- `pubspec.yaml`에 필수 패키지 추가
  - `supabase_flutter`
  - `google_sign_in`
  - `flutter_dotenv`
  - `flutter_riverpod` (상태 관리)

**완료 상태:** ✅ 완료 (2025-01-30)
- supabase_flutter: ^2.9.1 추가
- google_sign_in: ^6.2.2 추가
- flutter_dotenv: ^5.2.1 추가
- flutter pub get 완료

**커밋 메시지 (1-2, 1-3 통합):**
```
feat: Supabase 인증을 위한 Flutter 의존성 및 환경 변수 설정

- supabase_flutter, google_sign_in, flutter_dotenv 의존성 추가
- .env 파일 생성 및 Supabase 연결 정보 설정
- .env.example 템플릿 파일 생성
- .gitignore에 .env 추가하여 민감 정보 보호
```

### 1-3. 환경 변수 설정 ✅
**작업 내용:**
- `.env` 파일 생성 (Supabase URL, Anon Key)
- `.gitignore`에 `.env` 추가
- `.env.example` 파일 생성 (템플릿용)

**완료 상태:** ✅ 완료 (2025-01-30)
- .env 파일 생성 및 Supabase URL, Anon Key 설정 완료
- .env.example 템플릿 생성 완료
- .gitignore에 .env 추가 완료

**커밋 메시지:** (1-2와 통합)

---

## Phase 2: 폴더 구조 및 기본 모델 생성

### 2-1. 폴더 구조 생성 ✅
**작업 내용:**
- `lib/features/auth/` 폴더 구조 생성
  - models/, providers/, services/, widgets/, dialogs/, screens/
- `lib/features/profile/` 폴더 구조 생성
  - widgets/, dialogs/, screens/

**완료 상태:** ✅ 완료 (2025-01-30)
- features/auth 폴더 구조 생성 완료
- features/profile 폴더 구조 생성 완료

**커밋 메시지 (2-1, 2-2 통합):**
```
feat: 인증 및 프로필 기능 폴더 구조 및 UserVo 모델 생성

- features/auth 폴더 구조 추가 (models, providers, services, widgets, dialogs, screens)
- features/profile 폴더 구조 추가 (widgets, dialogs, screens)
- UserVo 모델 생성 (id, email, nickname, avatarUrl 등)
- JSON serialization 메서드 구현 (fromJson, toJson)
- hasNickname getter 및 copyWith 메서드 추가
```

### 2-2. UserVo 모델 생성 ✅
**작업 내용:**
- `lib/features/auth/models/vo_user.dart` 생성
- 필드: id, email, fullName, nickname, avatarUrl
- JSON serialization (fromJson, toJson)

**완료 상태:** ✅ 완료 (2025-01-30)
- UserVo 클래스 생성 완료
- fromJson, toJson 메서드 구현 완료
- hasNickname getter 추가
- copyWith 메서드 추가
- toString, operator ==, hashCode 구현

**커밋 메시지:** (2-1과 통합)

---

## Phase 3: 핵심 서비스 및 Provider 구현

### 3-1. AuthService 구현 (기본 기능) ✅
**작업 내용:**
- `lib/features/auth/services/auth_service.dart` 생성
- Supabase 클라이언트 초기화
- Google 로그인 메서드
- 로그아웃 메서드
- 현재 사용자 정보 조회

**완료 상태:** ✅ 완료 (2025-01-30)
- AuthService 클래스 생성 (Riverpod 패턴 적용)
- getCurrentUser() 메서드 구현
- signInWithGoogle() 메서드 구현
- signOut() 메서드 구현
- authStateChanges 스트림 추가
- AppLogger.auth 로거 추가
- Database Trigger SQL 작성 (docs/supabase_trigger.sql)

**커밋 메시지:**
```
feat: AuthService 기본 기능 구현 및 Database Trigger 추가

- AuthService 클래스 생성 (Riverpod 패턴)
- Google 로그인/로그아웃 메서드 구현
- 현재 사용자 정보 조회 메서드 추가
- 인증 상태 변경 스트림 추가
- AppLogger.auth 로거 추가
- Supabase Database Trigger SQL 작성 (profiles 자동 생성)
```

### 3-2. AuthService 확장 (닉네임 및 계정 관리) ✅
**작업 내용:**
- 닉네임 중복 검사 메서드
- 닉네임 업데이트 메서드
- 프로필 생성 메서드
- 계정 삭제 메서드

**완료 상태:** ✅ 완료 (2025-01-30)
- isNicknameAvailable() 메서드 구현
- updateNickname() 메서드 구현 (중복 검사 포함)
- deleteAccount() 메서드 구현
- Supabase delete_user_account() SQL Function 작성

**커밋 메시지:**
```
feat: AuthService 닉네임 및 계정 관리 기능 추가

- 닉네임 중복 검사 메서드 추가
- 닉네임 업데이트 메서드 추가 (중복 검사 포함)
- 계정 완전 삭제 메서드 추가 (profiles + auth.users)
- Supabase delete_user_account() SQL Function 작성
```

### 3-3. AuthProvider 구현 ✅
**작업 내용:**
- `lib/features/auth/providers/auth_provider.dart` 생성
- StateNotifier 또는 ChangeNotifier 기반 상태 관리
- 인증 상태 스트림 관리
- 로그인/로그아웃 이벤트 처리
- 닉네임 설정 여부 확인 로직

**완료 상태:** ✅ 완료 (2025-01-30)
- supabaseClientProvider 생성
- authServiceProvider 생성
- currentUserProvider (StreamProvider) 구현
- isAuthenticatedProvider 구현
- hasNicknameProvider 구현
- AuthNotifier (StateNotifier) 구현
- authNotifierProvider 생성
- supabaseInitProvider (초기화) 구현

**커밋 메시지:**
```
feat: AuthProvider 상태 관리 구현

- Riverpod Provider 기반 상태 관리 구현
- currentUserProvider로 인증 상태 스트림 관리
- isAuthenticatedProvider, hasNicknameProvider 추가
- AuthNotifier로 로그인/로그아웃/닉네임 관리 액션 처리
- supabaseInitProvider로 Supabase 초기화 관리
```

---

## Phase 4: 로그인 화면 구현

### 4-1. Google 로그인 버튼 위젯 ✅
**작업 내용:**
- `lib/features/auth/widgets/w_google_sign_in_button.dart` 생성
- Google 로고 + "Google로 로그인" 버튼 UI
- 로딩 상태 처리

**완료 상태:** ✅ 완료 (2025-01-30)
- w_google_sign_in_button.dart 생성 완료
- 로딩 상태 UI 추가
- Google 로그인 에러 처리 추가
- 테스트용 LoginTestScreen 추가 (s_login_test.dart)
- app.dart에 Supabase 초기화 및 테스트 화면 연동
- main.dart에 dotenv.load() 추가

**커밋 메시지:**
```
feat: Google 로그인 버튼 위젯 추가

- w_google_sign_in_button 구현
- 로딩 상태 UI 추가
```

### 4-2. LoginScreen 구현
**작업 내용:**
- `lib/features/auth/screens/s_login.dart` 생성
- 앱 로고 및 브랜딩
- Google 로그인 버튼 배치
- 에러 처리 (로그인 실패, 취소 등)

**커밋 메시지:**
```
feat: 로그인 화면 구현

- LoginScreen UI 구현
- Google 로그인 버튼 연동
- 로그인 에러 처리 추가
```

---

## Phase 5: 닉네임 설정 기능 구현

### 5-1. NicknameSetupScreen 구현
**작업 내용:**
- `lib/features/auth/screens/s_nickname_setup.dart` 생성
- 닉네임 입력 TextField
- 유효성 검증 (2-12자, 특수문자 제한)
- 실시간 중복 검사
- 기본 아바타 표시

**커밋 메시지:**
```
feat: 닉네임 설정 화면 구현

- NicknameSetupScreen UI 구현
- 닉네임 유효성 검증 로직 추가
- 실시간 중복 검사 기능 추가
```

### 5-2. 닉네임 설정 다이얼로그
**작업 내용:**
- `lib/features/auth/dialogs/d_nickname_setup.dart` 생성 (선택사항)
- 간단한 다이얼로그 형태의 닉네임 설정 UI

**커밋 메시지:**
```
feat: 닉네임 설정 다이얼로그 추가

- d_nickname_setup 다이얼로그 구현
- Screen 대체 옵션으로 활용 가능
```

---

## Phase 6: SplashScreen 및 라우팅 구현

### 6-1. SplashScreen 구현
**작업 내용:**
- `lib/features/auth/screens/s_splash.dart` 생성
- 앱 시작 시 인증 상태 확인
- 닉네임 설정 여부 확인
- 자동 라우팅 로직
  - 미인증 → LoginScreen
  - 인증 + 닉네임 미설정 → NicknameSetupScreen
  - 인증 + 닉네임 완료 → MainScreen

**커밋 메시지:**
```
feat: SplashScreen 및 자동 라우팅 구현

- SplashScreen UI 구현
- 인증 상태 기반 자동 라우팅 로직 추가
- 닉네임 설정 여부 확인 로직 추가
```

### 6-2. main.dart 라우팅 통합
**작업 내용:**
- `lib/main.dart` 수정
- SplashScreen을 초기 화면으로 설정
- 라우팅 설정 (go_router 또는 기본 Navigator)

**커밋 메시지:**
```
feat: 앱 라우팅 설정 및 SplashScreen 통합

- main.dart에 SplashScreen 초기 화면 설정
- 라우팅 구조 정의
```

---

## Phase 7: 프로필 화면 구현 (로그인 전/후)

### 7-1. 공통 위젯 생성
**작업 내용:**
- `lib/features/auth/widgets/w_default_avatar.dart` - 기본 아바타 위젯
- `lib/features/profile/widgets/w_profile_header.dart` - 프로필 헤더
- `lib/features/profile/widgets/w_profile_menu_item.dart` - 메뉴 아이템

**커밋 메시지:**
```
feat: 프로필 관련 공통 위젯 추가

- w_default_avatar 구현
- w_profile_header 구현
- w_profile_menu_item 구현
```

### 7-2. ProfileScreen 로그인 전 상태 구현
**작업 내용:**
- `lib/features/profile/screens/s_profile.dart` 수정
- 로그인 전 UI:
  - 기본 아바타
  - "로그인이 필요합니다" 메시지
  - 로그인 버튼 → LoginScreen 이동

**커밋 메시지:**
```
feat: ProfileScreen 로그인 전 상태 구현

- 로그인 전 UI 추가 (기본 아바타, 로그인 버튼)
- LoginScreen으로 이동하는 네비게이션 추가
```

### 7-3. ProfileScreen 로그인 후 상태 구현
**작업 내용:**
- ProfileScreen 로그인 후 UI:
  - 프로필 헤더 (프로필 이미지, 닉네임, 이메일)
  - 메뉴 리스트 (닉네임 변경, 계정 설정, 앱 정보, 버전 정보)
- AuthProvider와 연동

**커밋 메시지:**
```
feat: ProfileScreen 로그인 후 상태 구현

- 프로필 정보 표시 UI 추가
- 메뉴 리스트 구현 (닉네임 변경, 계정 설정 등)
- AuthProvider와 상태 연동
```

---

## Phase 8: 닉네임 변경 기능 구현

### 8-1. 닉네임 변경 다이얼로그
**작업 내용:**
- `lib/features/profile/dialogs/d_edit_nickname.dart` 생성
- 현재 닉네임 표시
- 새 닉네임 입력 TextField
- 유효성 검증 및 중복 검사
- 저장 버튼

**커밋 메시지:**
```
feat: 닉네임 변경 다이얼로그 구현

- d_edit_nickname 다이얼로그 UI 구현
- 닉네임 유효성 검증 및 중복 검사 추가
- AuthService와 연동하여 업데이트 기능 구현
```

### 8-2. ProfileScreen에 닉네임 변경 연동
**작업 내용:**
- ProfileScreen 메뉴에서 닉네임 변경 다이얼로그 호출
- 닉네임 변경 후 UI 업데이트

**커밋 메시지:**
```
feat: ProfileScreen에 닉네임 변경 기능 연동

- 닉네임 변경 메뉴 클릭 시 다이얼로그 표시
- 닉네임 업데이트 후 UI 자동 갱신
```

---

## Phase 9: 계정 설정 화면 구현

### 9-1. AccountSettingsScreen 구현
**작업 내용:**
- `lib/features/profile/screens/s_account_settings.dart` 생성
- 연동된 계정 정보 표시 (Google 계정)
- 로그아웃 버튼
- 계정 삭제 버튼

**커밋 메시지:**
```
feat: 계정 설정 화면 구현

- AccountSettingsScreen UI 구현
- 연동된 계정 정보 표시
- 로그아웃 및 계정 삭제 버튼 추가
```

### 9-2. 로그아웃 확인 다이얼로그
**작업 내용:**
- `lib/features/auth/dialogs/d_logout_confirm.dart` 생성
- 로그아웃 확인 메시지
- 확인/취소 버튼
- AuthService 로그아웃 메서드 호출

**커밋 메시지:**
```
feat: 로그아웃 확인 다이얼로그 구현

- d_logout_confirm 다이얼로그 UI 구현
- 로그아웃 로직 연동
- 확인 시 LoginScreen으로 이동
```

### 9-3. 계정 삭제 확인 다이얼로그
**작업 내용:**
- `lib/features/auth/dialogs/d_account_delete_confirm.dart` 생성
- 경고 메시지 (데이터 삭제 안내)
- 최종 확인 다이얼로그
- AuthService 계정 삭제 메서드 호출
- 로컬 데이터 정리

**커밋 메시지:**
```
feat: 계정 삭제 확인 다이얼로그 구현

- d_account_delete_confirm 다이얼로그 UI 구현
- 경고 메시지 및 최종 확인 단계 추가
- 계정 삭제 및 로컬 데이터 정리 로직 연동
```

---

## Phase 10: 에러 처리 및 사용자 경험 개선

### 10-1. 전역 에러 처리
**작업 내용:**
- 네트워크 오류 처리
- 로그인 실패 처리
- 닉네임 중복 에러 처리
- 사용자 친화적인 에러 메시지 표시

**커밋 메시지:**
```
feat: 전역 에러 처리 및 사용자 메시지 개선

- 네트워크 오류 처리 로직 추가
- 로그인 실패 시 사용자 친화적 메시지 표시
- 닉네임 중복 에러 처리 개선
```

### 10-2. 로딩 상태 UI 개선
**작업 내용:**
- 로그인 중 로딩 인디케이터
- 닉네임 중복 확인 중 로딩 상태
- 계정 삭제 중 로딩 상태

**커밋 메시지:**
```
feat: 로딩 상태 UI 개선

- 로그인, 닉네임 확인, 계정 삭제 시 로딩 인디케이터 추가
- 사용자 피드백 개선
```

---

## Phase 11: 테스트 및 버그 수정

### 11-1. 통합 테스트
**작업 내용:**
- 첫 회원가입 플로우 테스트
- 재로그인 플로우 테스트
- 로그아웃 테스트
- 계정 삭제 테스트
- 닉네임 변경 테스트

**커밋 메시지:**
```
test: 인증 기능 통합 테스트 추가

- 회원가입, 로그인, 로그아웃 플로우 테스트
- 닉네임 설정 및 변경 테스트
- 계정 삭제 테스트
```

### 11-2. 버그 수정 및 리팩토링
**작업 내용:**
- 발견된 버그 수정
- 코드 리팩토링
- 성능 최적화

**커밋 메시지:**
```
fix: 인증 기능 버그 수정 및 코드 개선

- [구체적인 버그 내용]
- 코드 리팩토링 및 성능 최적화
```

---

## Phase 12: 문서화 및 최종 정리

### 12-1. README 업데이트
**작업 내용:**
- 인증 기능 사용 방법 문서화
- 환경 변수 설정 가이드
- Supabase 설정 가이드

**커밋 메시지:**
```
docs: 인증 기능 문서 업데이트

- README에 인증 기능 사용 가이드 추가
- 환경 변수 설정 방법 문서화
- Supabase 설정 가이드 추가
```

### 12-2. 최종 정리
**작업 내용:**
- 미사용 코드 제거
- import 정리
- 코드 포맷팅

**커밋 메시지:**
```
chore: 인증 기능 최종 정리

- 미사용 코드 제거
- import 정리 및 코드 포맷팅
```

---

## 커밋 메시지 컨벤션

### 타입 (Type)
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정
- `chore`: 빌드, 설정 파일 수정
- `refactor`: 코드 리팩토링
- `test`: 테스트 코드 추가/수정
- `style`: 코드 포맷팅 (기능 변경 없음)

### 형식
```
<타입>: <제목>

- <상세 내용 1>
- <상세 내용 2>
- <상세 내용 3>
```

### 예시
```
feat: Google 로그인 기능 구현

- AuthService에 Google OAuth 로그인 메서드 추가
- LoginScreen에 Google 로그인 버튼 연동
- 로그인 성공 시 MainScreen으로 이동
```

---

## 추정 소요 시간

| Phase | 작업 내용 | 예상 시간 |
|-------|----------|----------|
| Phase 1 | 환경 설정 및 의존성 | 1-2시간 |
| Phase 2 | 폴더 구조 및 모델 | 1시간 |
| Phase 3 | 서비스 및 Provider | 3-4시간 |
| Phase 4 | 로그인 화면 | 2-3시간 |
| Phase 5 | 닉네임 설정 | 2-3시간 |
| Phase 6 | SplashScreen 및 라우팅 | 2시간 |
| Phase 7 | 프로필 화면 | 3-4시간 |
| Phase 8 | 닉네임 변경 | 1-2시간 |
| Phase 9 | 계정 설정 | 2-3시간 |
| Phase 10 | 에러 처리 및 UX | 2-3시간 |
| Phase 11 | 테스트 및 버그 수정 | 3-4시간 |
| Phase 12 | 문서화 및 정리 | 1-2시간 |
| **총계** | | **23-33시간** |

---

## 우선순위

### P0 (필수)
- Phase 1-6: 기본 로그인 및 닉네임 설정
- Phase 7: 프로필 화면 (로그인 전/후)
- Phase 9.2: 로그아웃 기능

### P1 (중요)
- Phase 8: 닉네임 변경
- Phase 9.3: 계정 삭제
- Phase 10: 에러 처리

### P2 (선택)
- Phase 11: 테스트
- Phase 12: 문서화

---

## 참고 사항

1. **병렬 작업 가능**
   - Phase 4, 5는 독립적으로 진행 가능
   - Phase 7, 8, 9는 Phase 3 완료 후 병렬 진행 가능

2. **MVP (Minimum Viable Product)**
   - P0 단계만 완료하면 기본적인 인증 시스템 동작 가능

3. **점진적 개선**
   - 각 Phase를 완료할 때마다 커밋
   - 기능 단위로 작은 커밋 유지
   - PR은 Phase 단위 또는 2-3개 Phase 묶어서 생성