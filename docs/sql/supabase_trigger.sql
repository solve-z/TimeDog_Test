-- ============================================
-- Supabase Database Trigger 설정
-- ============================================
-- 목적: auth.users에 새 사용자 생성 시 자동으로 profiles 테이블에 기본 레코드 생성
-- 작성일: 2025-01-30

-- 1. 새 사용자 처리 함수 생성
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, created_at)
  VALUES (
    new.id,
    new.email,
    new.created_at
  );
  RETURN new;
END;
$$;

-- 2. 트리거 생성 (auth.users에 INSERT 발생 시 자동 실행)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- 설치 방법
-- ============================================
-- 1. Supabase Dashboard → SQL Editor 접속
-- 2. 위 SQL을 복사하여 실행
-- 3. 테스트: Google 로그인 → profiles 테이블 자동 생성 확인

-- ============================================
-- 주의사항
-- ============================================
-- - 이미 존재하는 auth.users는 자동으로 profiles에 추가되지 않음
-- - 기존 사용자는 수동으로 profiles 레코드 생성 필요
-- - 또는 아래 마이그레이션 스크립트 실행:

-- 기존 사용자 마이그레이션 (선택사항)
-- INSERT INTO public.profiles (id, email, created_at)
-- SELECT id, email, created_at
-- FROM auth.users
-- WHERE id NOT IN (SELECT id FROM public.profiles)
-- ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 계정 삭제 함수
-- ============================================
-- 목적: 사용자 계정 완전 삭제 (profiles + auth.users)
-- 작성일: 2025-01-30

-- 계정 삭제 함수 생성
CREATE OR REPLACE FUNCTION public.delete_user_account()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_id uuid;
BEGIN
  -- 현재 로그인된 사용자 ID 가져오기
  user_id := auth.uid();

  IF user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- 1. profiles 테이블에서 사용자 데이터 삭제
  DELETE FROM public.profiles WHERE id = user_id;

  -- 2. auth.users 테이블에서 사용자 삭제
  DELETE FROM auth.users WHERE id = user_id;

  -- 로그 기록 (선택사항)
  RAISE NOTICE 'User account deleted: %', user_id;
END;
$$;

-- ============================================
-- 사용 방법 (Flutter에서 호출)
-- ============================================
-- await supabase.rpc('delete_user_account');

-- ============================================
-- 주의사항
-- ============================================
-- - 이 함수는 SECURITY DEFINER로 실행되므로 RLS를 우회할 수 있음
-- - auth.users 삭제는 되돌릴 수 없음
-- - 필요시 CASCADE 삭제를 위해 다른 테이블도 정리해야 할 수 있음