# 인증 기능 명세서 (Authentication Specification)

## 개요

TimeDog 앱의 Google 소셜 로그인 및 Supabase 기반 인증 시스템 구현 명세

## 기술 스택

- **인증 제공자**: Google OAuth 2.0
- **백엔드**: Supabase (Authentication + Database)
- **상태 관리**: Provider/Riverpod
- **플랫폼**: Android, iOS, Web, Windows

## 주요 기능

### 1. 로그인/회원가입
- Google 소셜 로그인
- 자동 회원가입 (첫 로그인 시)
- 닉네임 설정 (첫 가입 시 필수)
- 로그인 상태 유지

### 2. 사용자 프로필
- Google 계정 정보 표시 (이름, 이메일, 프로필 이미지)
- 닉네임 변경
- 프로필 이미지 변경 (선택사항)
- 사용자 설정 관리

### 3. 계정 관리
- 로그아웃
- 계정 삭제 (탈퇴)
- 세션 종료
- 로컬 데이터 정리

## 구현 단계

### Phase 1: Supabase 설정
1. Supabase 프로젝트 생성
2. Google OAuth Provider 설정
3. 환경 변수 설정 (.env)

### Phase 2: Flutter 의존성 추가
```yaml
dependencies:
  supabase_flutter: ^latest
  google_sign_in: ^latest
  flutter_dotenv: ^latest
```

### Phase 3: 폴더 구조
```
lib/
├── features/
│   └── auth/
│       ├── models/
│       │   └── vo_user.dart
│       ├── providers/
│       │   └── auth_provider.dart
│       ├── services/
│       │   └── auth_service.dart
│       ├── widgets/
│       │   ├── w_google_sign_in_button.dart
│       │   ├── w_user_profile_card.dart
│       │   └── w_default_avatar.dart
│       ├── dialogs/
│       │   ├── d_nickname_setup.dart
│       │   ├── d_logout_confirm.dart
│       │   └── d_account_delete_confirm.dart
│       └── screens/
│           ├── s_login.dart
│           ├── s_splash.dart
│           └── s_nickname_setup.dart
│   └── profile/
│       ├── widgets/
│       │   ├── w_profile_header.dart
│       │   ├── w_profile_menu_item.dart
│       │   └── w_account_settings_section.dart
│       ├── dialogs/
│       │   └── d_edit_nickname.dart
│       └── screens/
│           ├── s_profile.dart (기존 파일 수정)
│           └── s_account_settings.dart
```

### Phase 4: 주요 컴포넌트

#### 1. AuthService (`lib/features/auth/services/auth_service.dart`)
- Supabase 클라이언트 초기화
- Google 로그인/로그아웃 로직
- 세션 관리
- 사용자 정보 조회
- 닉네임 업데이트
- 계정 삭제

#### 2. AuthProvider (`lib/features/auth/providers/auth_provider.dart`)
- 인증 상태 관리
- UI와 Service 연결
- 로그인/로그아웃 이벤트 처리
- 닉네임 설정 여부 확인

#### 3. UserVo (`lib/features/auth/models/vo_user.dart`)
- 사용자 데이터 모델 (id, email, fullName, nickname, avatarUrl)
- JSON serialization

#### 4. LoginScreen (`lib/features/auth/screens/s_login.dart`)
- 앱 로고 및 브랜딩
- Google 로그인 버튼 (w_google_sign_in_button)
- 로그인 방법 선택 UI

#### 5. NicknameSetupScreen (`lib/features/auth/screens/s_nickname_setup.dart`)
- 첫 가입 시 닉네임 입력 화면
- 닉네임 중복 검사
- 닉네임 유효성 검증 (2-12자, 특수문자 제한)
- 기본 아바타 표시

#### 6. SplashScreen (`lib/features/auth/screens/s_splash.dart`)
- 앱 시작 시 인증 상태 확인
- 자동 로그인 처리
- 닉네임 설정 여부 확인
- 적절한 화면으로 리다이렉트
  - 미인증 → LoginScreen
  - 인증 + 닉네임 미설정 → NicknameSetupScreen
  - 인증 + 닉네임 설정완료 → MainScreen

#### 7. ProfileScreen (`lib/features/profile/screens/s_profile.dart`)
**로그인 전 상태:**
- 기본 아바타 이미지 (w_default_avatar)
- "로그인이 필요합니다" 메시지
- 로그인 버튼

**로그인 후 상태:**
- 프로필 헤더 (w_profile_header)
  - 프로필 이미지 (Google 프로필 or 기본 아바타)
  - 닉네임
  - 이메일
- 프로필 메뉴 리스트
  - 닉네임 변경 (d_edit_nickname)
  - 계정 설정 (s_account_settings로 이동)
  - 앱 정보
  - 버전 정보

#### 8. AccountSettingsScreen (`lib/features/profile/screens/s_account_settings.dart`)
- 로그아웃 버튼 (d_logout_confirm)
- 계정 삭제 버튼 (d_account_delete_confirm)
- 연동된 계정 정보 표시

### Phase 5: 환경 설정

#### .env 파일
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

#### .gitignore 추가
```
.env
```

### Phase 6: 라우팅 설정
- 앱 시작 → SplashScreen
  - 미인증 → LoginScreen
  - 인증 + 닉네임 미설정 → NicknameSetupScreen
  - 인증 + 닉네임 설정완료 → MainScreen
- ProfileScreen 내 로그인 버튼 → LoginScreen
- 계정 설정 메뉴 → AccountSettingsScreen

## 데이터베이스 스키마 (Supabase)

### users 테이블 (자동 생성됨)
Supabase Auth가 자동으로 관리

### profiles 테이블 (커스텀)
```sql
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  full_name text,
  nickname text unique not null,
  avatar_url text,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null
);

-- 닉네임 인덱스 (중복 검사 성능 향상)
create index profiles_nickname_idx on profiles(nickname);

-- RLS 정책
alter table profiles enable row level security;

create policy "Users can view own profile"
  on profiles for select
  using ( auth.uid() = id );

create policy "Users can update own profile"
  on profiles for update
  using ( auth.uid() = id );

create policy "Users can insert own profile"
  on profiles for insert
  with check ( auth.uid() = id );

-- 닉네임 중복 확인을 위한 public read 정책 (닉네임만)
create policy "Anyone can check nickname availability"
  on profiles for select
  using ( true );
```

## 보안 고려사항

1. **환경 변수**: API 키는 절대 코드에 하드코딩하지 않음
2. **RLS (Row Level Security)**: Supabase에서 반드시 활성화
3. **토큰 관리**: Supabase SDK가 자동 처리
4. **민감 정보 로깅 금지**: 로그에 토큰/키 출력 금지

## UI 플로우

### 1. 첫 회원가입 플로우
```
SplashScreen
  → LoginScreen (로그인 필요)
    → Google 로그인 버튼 클릭
    → Google 계정 선택
    → 첫 로그인 감지
  → NicknameSetupScreen
    → 닉네임 입력 (2-12자)
    → 중복 확인
    → 저장
  → MainScreen (ProfileScreen)
    → 프로필 정보 표시
```

### 2. 재로그인 플로우
```
SplashScreen
  → 세션 확인 (유효)
  → 닉네임 설정 확인 (완료)
  → MainScreen
```

### 3. 로그아웃 플로우
```
ProfileScreen
  → 계정 설정 메뉴 클릭
  → AccountSettingsScreen
  → 로그아웃 버튼 클릭
  → LogoutConfirmDialog
  → 확인
  → LoginScreen
```

### 4. 계정 삭제 플로우
```
ProfileScreen
  → 계정 설정 메뉴 클릭
  → AccountSettingsScreen
  → 계정 삭제 버튼 클릭
  → AccountDeleteConfirmDialog
  → 경고 메시지 확인
  → 최종 확인
  → Supabase 계정 삭제 + 로컬 데이터 삭제
  → LoginScreen
```

### 5. 닉네임 변경 플로우
```
ProfileScreen
  → 닉네임 변경 메뉴 클릭
  → EditNicknameDialog
  → 새 닉네임 입력
  → 중복 확인
  → 저장
  → ProfileScreen (업데이트된 닉네임 표시)
```

## 테스트 시나리오

1. **첫 로그인 (회원가입)**
   - Google 로그인 성공
   - 닉네임 설정 화면 표시
   - 닉네임 유효성 검증 (2-12자, 특수문자 제한)
   - 닉네임 중복 검사
   - 프로필 저장 및 메인 화면 이동

2. **재로그인 (기존 사용자)**
   - 앱 시작 시 세션 자동 복구
   - 닉네임 설정 확인
   - 메인 화면으로 바로 이동

3. **로그인 전 ProfileScreen**
   - 기본 아바타 표시
   - "로그인이 필요합니다" 메시지
   - 로그인 버튼 클릭 → LoginScreen 이동

4. **로그아웃**
   - 로그아웃 확인 다이얼로그
   - 세션 종료 확인
   - LoginScreen 이동

5. **계정 삭제**
   - 경고 메시지 표시
   - 최종 확인 다이얼로그
   - Supabase 계정 삭제
   - 로컬 데이터 정리
   - LoginScreen 이동

6. **닉네임 변경**
   - 중복 검사
   - 유효성 검증
   - 업데이트 성공
   - UI 반영

7. **네트워크 오류 처리**
   - 로그인 실패 메시지
   - 닉네임 중복 확인 실패 처리
   - 재시도 옵션

8. **로그인 취소 처리**
   - Google 로그인 취소 시 LoginScreen 유지
   - 적절한 안내 메시지

## 다음 단계

1. Supabase 프로젝트 생성 및 설정
2. 의존성 추가 (`pubspec.yaml`)
3. 폴더 구조 생성
4. 핵심 서비스/Provider 구현
5. UI 화면 구현
6. 라우팅 통합
7. 테스트

## 참고 자료

- [Supabase Flutter 문서](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [Supabase Auth 가이드](https://supabase.com/docs/guides/auth)
