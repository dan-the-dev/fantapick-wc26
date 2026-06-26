-- ============================================================
-- FantaPick WC26 — initial schema
-- ============================================================

-- rounds (lookup table, never changes during a tournament)
create table if not exists public.rounds (
  id          text primary key,
  label_it    text not null,
  order_num   integer not null,
  teams_count integer not null
);

-- round_state — one row per round, tracks upcoming/live/completed
create table if not exists public.round_state (
  id         uuid primary key default gen_random_uuid(),
  round      text not null unique references public.rounds(id),
  state      text not null default 'upcoming',
  updated_at timestamptz default now()
);

-- drafts — one row per (player, round)
create table if not exists public.drafts (
  id               uuid primary key default gen_random_uuid(),
  nickname         text not null,
  round            text not null references public.rounds(id),
  coach            jsonb,           -- CT object { name, team, flag, formation }
  picks            jsonb,           -- breakdown array of player objects
  formation        jsonb,           -- formation string e.g. "4-3-3"
  captain          text,            -- playerKey "Name|Team"
  score            numeric default 0,
  swap_count       integer default 0,
  retry_used       boolean default false,
  ct_bonus_applied boolean not null default false,
  ts               bigint,          -- client timestamp ms
  created_at       timestamptz default now(),
  updated_at       timestamptz default now(),
  constraint drafts_round_nickname_unique unique (round, nickname)
);

-- match_data — admin-entered per-match stats
create table if not exists public.match_data (
  id           uuid primary key default gen_random_uuid(),
  round        text not null references public.rounds(id),
  match_id     text not null,
  home_team    text not null default '',
  away_team    text not null default '',
  home_score   integer default 0,
  away_score   integer default 0,
  completed    boolean default false,
  player_stats jsonb default '{}'::jsonb,
  winner_team  text,
  match_date   timestamptz,
  created_at   timestamptz default now(),
  updated_at   timestamptz default now(),
  constraint match_data_round_match_id_unique unique (round, match_id)
);

-- qualified_teams — which teams can be drafted in each round
create table if not exists public.qualified_teams (
  round      text not null references public.rounds(id),
  team_code  text not null,
  primary key (round, team_code)
);

-- ============================================================
-- Indexes
-- ============================================================
create index if not exists idx_drafts_round       on public.drafts(round);
create index if not exists idx_drafts_round_score on public.drafts(round, score desc);
create index if not exists idx_match_data_round   on public.match_data(round);

-- ============================================================
-- updated_at trigger
-- ============================================================
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_drafts_updated_at    on public.drafts;
drop trigger if exists trg_match_data_updated_at on public.match_data;

create trigger trg_drafts_updated_at
  before update on public.drafts
  for each row execute function public.set_updated_at();

create trigger trg_match_data_updated_at
  before update on public.match_data
  for each row execute function public.set_updated_at();

-- ============================================================
-- Row Level Security — full anon access (no auth in this app)
-- ============================================================
alter table public.rounds          enable row level security;
alter table public.round_state     enable row level security;
alter table public.drafts          enable row level security;
alter table public.match_data      enable row level security;
alter table public.qualified_teams enable row level security;

-- rounds (read-only)
drop policy if exists "anon_select_rounds" on public.rounds;
create policy "anon_select_rounds" on public.rounds for select to anon using (true);

-- round_state
drop policy if exists "anon_select_round_state" on public.round_state;
drop policy if exists "anon_insert_round_state" on public.round_state;
drop policy if exists "anon_update_round_state" on public.round_state;
create policy "anon_select_round_state" on public.round_state for select to anon using (true);
create policy "anon_insert_round_state" on public.round_state for insert to anon with check (true);
create policy "anon_update_round_state" on public.round_state for update to anon using (true) with check (true);

-- drafts
drop policy if exists "anon_select_drafts" on public.drafts;
drop policy if exists "anon_insert_drafts" on public.drafts;
drop policy if exists "anon_update_drafts" on public.drafts;
drop policy if exists "anon_delete_drafts" on public.drafts;
create policy "anon_select_drafts" on public.drafts for select to anon using (true);
create policy "anon_insert_drafts" on public.drafts for insert to anon with check (true);
create policy "anon_update_drafts" on public.drafts for update to anon using (true) with check (true);
create policy "anon_delete_drafts" on public.drafts for delete to anon using (true);

-- match_data
drop policy if exists "anon_select_match_data" on public.match_data;
drop policy if exists "anon_insert_match_data" on public.match_data;
drop policy if exists "anon_update_match_data" on public.match_data;
drop policy if exists "anon_delete_match_data" on public.match_data;
create policy "anon_select_match_data" on public.match_data for select to anon using (true);
create policy "anon_insert_match_data" on public.match_data for insert to anon with check (true);
create policy "anon_update_match_data" on public.match_data for update to anon using (true) with check (true);
create policy "anon_delete_match_data" on public.match_data for delete to anon using (true);

-- qualified_teams
drop policy if exists "anon_select_qualified_teams" on public.qualified_teams;
drop policy if exists "anon_insert_qualified_teams" on public.qualified_teams;
drop policy if exists "anon_delete_qualified_teams" on public.qualified_teams;
create policy "anon_select_qualified_teams" on public.qualified_teams for select to anon using (true);
create policy "anon_insert_qualified_teams" on public.qualified_teams for insert to anon with check (true);
create policy "anon_delete_qualified_teams" on public.qualified_teams for delete to anon using (true);

-- ============================================================
-- Seed static data
-- ============================================================
insert into public.rounds (id, label_it, order_num, teams_count) values
  ('r32',   'Sedicesimi', 1, 32),
  ('r16',   'Ottavi',     2, 16),
  ('qf',    'Quarti',     3,  8),
  ('sf',    'Semifinali', 4,  4),
  ('final', 'Finale',     5,  2)
on conflict (id) do nothing;

insert into public.round_state (round, state) values
  ('r32',   'upcoming'),
  ('r16',   'upcoming'),
  ('qf',    'upcoming'),
  ('sf',    'upcoming'),
  ('final', 'upcoming')
on conflict (round) do nothing;
