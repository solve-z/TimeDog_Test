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