-- ============================================================
-- 매칭표 기능 추가 마이그레이션
-- 이미 setup.sql을 실행하셨다면, 이 파일만 추가로 실행하세요.
-- (Supabase SQL Editor에서 실행)
-- ============================================================

-- 정기모임 생성 시 "인당 게임 횟수"를 저장할 컬럼
alter table tc_events add column if not exists games_per_person integer;

-- 생성된 복식 매칭표를 저장할 컬럼 (라운드/코트/팀 구성을 JSON으로 저장)
alter table tc_events add column if not exists match_schedule jsonb;
