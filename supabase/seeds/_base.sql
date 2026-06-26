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

-- 32 qualified teams for Sedicesimi
-- Team names match squads-complete.json exactly (full name, not abbreviation)
insert into public.qualified_teams (round, team_code) values
  ('r32', 'Argentina'),
  ('r32', 'Australia'),
  ('r32', 'Belgium'),
  ('r32', 'Brazil'),
  ('r32', 'Canada'),
  ('r32', 'Chile'),
  ('r32', 'Colombia'),
  ('r32', 'Costa Rica'),
  ('r32', 'Croatia'),
  ('r32', 'Denmark'),
  ('r32', 'Ecuador'),
  ('r32', 'Egypt'),
  ('r32', 'England'),
  ('r32', 'France'),
  ('r32', 'Germany'),
  ('r32', 'Italy'),
  ('r32', 'Japan'),
  ('r32', 'Mexico'),
  ('r32', 'Morocco'),
  ('r32', 'Netherlands'),
  ('r32', 'Nigeria'),
  ('r32', 'Poland'),
  ('r32', 'Portugal'),
  ('r32', 'Senegal'),
  ('r32', 'Serbia'),
  ('r32', 'South Korea'),
  ('r32', 'Spain'),
  ('r32', 'Sweden'),
  ('r32', 'Switzerland'),
  ('r32', 'Uruguay'),
  ('r32', 'USA'),
  ('r32', 'Wales')
on conflict do nothing;
