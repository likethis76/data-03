-- ============================================================
-- 코트사이드 테니스 클럽 - 데이터베이스 설정
-- 모든 테이블은 접두어 tc_ (Tennis Club) 사용
-- Supabase 대시보드 > SQL Editor 에서 전체 실행하세요.
-- ============================================================

-- 1. 게시글 테이블 (공지사항 + 자유게시판 공용, board_type 으로 구분)
create table if not exists tc_posts (
  id           bigint generated always as identity primary key,
  board_type   text not null check (board_type in ('notice', 'free')),
  title        text not null,
  author       text not null,
  content      text not null,
  views        integer not null default 0,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);

-- 2. 댓글 테이블
create table if not exists tc_comments (
  id           bigint generated always as identity primary key,
  post_id      bigint not null references tc_posts(id) on delete cascade,
  author       text not null,
  content      text not null,
  created_at   timestamptz not null default now()
);

-- 3. 모임(이벤트) 테이블 - 정기모임 / 소모임 공용, event_type 으로 구분
create table if not exists tc_events (
  id                bigint generated always as identity primary key,
  event_type        text not null check (event_type in ('regular', 'small')),
  title             text not null,
  event_date        date not null,
  event_time        text,
  location          text not null,
  max_participants  integer,
  description       text,
  host_name         text,
  games_per_person  integer,
  match_schedule    jsonb,
  created_at        timestamptz not null default now()
);

-- 4. 모임 신청 테이블
create table if not exists tc_applications (
  id             bigint generated always as identity primary key,
  event_id       bigint not null references tc_events(id) on delete cascade,
  applicant_name text not null,
  phone          text,
  memo           text,
  created_at     timestamptz not null default now()
);

-- ------------------------------------------------------------
-- 인덱스
-- ------------------------------------------------------------
create index if not exists idx_tc_posts_board_type on tc_posts(board_type);
create index if not exists idx_tc_comments_post_id on tc_comments(post_id);
create index if not exists idx_tc_events_event_type on tc_events(event_type);
create index if not exists idx_tc_applications_event_id on tc_applications(event_id);

-- ------------------------------------------------------------
-- RLS 활성화
-- 로그인 기능이 없는 "이름만 입력" 방식이므로, anon 키로
-- 읽기/쓰기/수정/삭제가 모두 가능하도록 열어둡니다.
-- (주의: 소규모 동호회 내부용 사이트에 적합한 신뢰 기반 설정입니다.
--  악용 우려가 있다면 추후 관리자 인증을 추가하는 것을 권장합니다.)
-- ------------------------------------------------------------
alter table tc_posts enable row level security;
alter table tc_comments enable row level security;
alter table tc_events enable row level security;
alter table tc_applications enable row level security;

drop policy if exists "tc_posts_all" on tc_posts;
create policy "tc_posts_all" on tc_posts for all using (true) with check (true);

drop policy if exists "tc_comments_all" on tc_comments;
create policy "tc_comments_all" on tc_comments for all using (true) with check (true);

drop policy if exists "tc_events_all" on tc_events;
create policy "tc_events_all" on tc_events for all using (true) with check (true);

drop policy if exists "tc_applications_all" on tc_applications;
create policy "tc_applications_all" on tc_applications for all using (true) with check (true);

-- ------------------------------------------------------------
-- 샘플 데이터 (사이트 확인용, 필요 없으면 삭제하세요)
-- ------------------------------------------------------------
insert into tc_posts (board_type, title, author, content) values
('notice', '동호회 회칙 안내', '운영진', '안녕하세요. 코트사이드 테니스 클럽 회칙을 안내드립니다.\n\n1. 월 회비는 3만원이며 매월 정기모임 시 코트 대관료로 사용됩니다.\n2. 정기모임은 매월 첫째 주 토요일, 소모임은 회원 누구나 자유롭게 개설할 수 있습니다.\n3. 모임 불참 시 최소 하루 전에는 게시판을 통해 알려주세요.'),
('notice', '9월 정기모임 코트 변경 안내', '운영진', '이번 달 정기모임 장소가 우천으로 인해 실내 코트로 변경되었습니다. 정기모임 게시판을 확인해주세요.'),
('free', '초보인데 라켓 추천 부탁드려요', '김테니', '테니스 시작한 지 한 달 된 초보입니다. 입문용 라켓 추천 부탁드려요!'),
('free', '오늘 시합 재밌었습니다', '박포핸드', '오늘 소모임에서 다들 실력이 많이 느신 것 같아요. 다음에도 같이 쳐요~');

insert into tc_events (event_type, title, event_date, event_time, location, max_participants, description, host_name) values
('regular', '9월 정기모임', '2026-09-05', '09:00 ~ 12:00', '올림픽공원 테니스코트 3, 4번', 16, '매월 첫째 주 토요일 정기모임입니다. 초보자도 편하게 참여하세요.', '운영진'),
('regular', '10월 정기모임', '2026-10-03', '09:00 ~ 12:00', '올림픽공원 테니스코트 3, 4번', 16, '10월 정기모임 안내입니다.', '운영진'),
('small', '평일 저녁 번개모임', '2026-09-17', '19:00 ~ 21:00', '잠실 테니스장 1번 코트', 4, '평일 저녁에 가볍게 랠리 치실 분 구합니다.', '이백핸드'),
('small', '주말 복식 매치', '2026-09-20', '14:00 ~ 16:00', '한강 테니스코트', 4, '복식 위주로 편하게 게임할 분 모집합니다.', '최발리');
