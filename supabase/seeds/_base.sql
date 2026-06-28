-- ============================================================
-- _base.sql — static data shared by all scenarios
-- Run this AFTER truncating tables.
-- ============================================================

-- Rounds
insert into public.rounds (id, label_it, order_num, teams_count) values
  ('r32',   'Sedicesimi', 1, 32),
  ('r16',   'Ottavi',     2, 16),
  ('qf',    'Quarti',     3,  8),
  ('sf',    'Semifinali', 4,  4),
  ('final', 'Finale',     5,  2)
on conflict (id) do nothing;

-- Round state — all upcoming (scenario files will override)
insert into public.round_state (round, state) values
  ('r32',   'upcoming'),
  ('r16',   'upcoming'),
  ('qf',    'upcoming'),
  ('sf',    'upcoming'),
  ('final', 'upcoming')
on conflict (round) do update set state = 'upcoming', updated_at = now();

-- 32 qualified teams for Sedicesimi — 3-letter codes matching squads-complete.json and fixtures-r32.json
insert into public.qualified_teams (round, team_code) values
  ('r32', 'ALG'),
  ('r32', 'ARG'),
  ('r32', 'AUS'),
  ('r32', 'AUT'),
  ('r32', 'BEL'),
  ('r32', 'BIH'),
  ('r32', 'BRA'),
  ('r32', 'CAN'),
  ('r32', 'CIV'),
  ('r32', 'COD'),
  ('r32', 'COL'),
  ('r32', 'CPV'),
  ('r32', 'CRO'),
  ('r32', 'ECU'),
  ('r32', 'EGY'),
  ('r32', 'ENG'),
  ('r32', 'ESP'),
  ('r32', 'FRA'),
  ('r32', 'GER'),
  ('r32', 'GHA'),
  ('r32', 'JPN'),
  ('r32', 'MAR'),
  ('r32', 'MEX'),
  ('r32', 'NED'),
  ('r32', 'NOR'),
  ('r32', 'PAR'),
  ('r32', 'POR'),
  ('r32', 'RSA'),
  ('r32', 'SEN'),
  ('r32', 'SUI'),
  ('r32', 'SWE'),
  ('r32', 'USA')
on conflict do nothing;
