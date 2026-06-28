-- match_data for r32 — 16 real WC2026 Sedicesimi di Finale
-- match_id format: HOME_AWAY (3-letter codes)
-- Scores/stats will be filled by admin when matches are played
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('r32', 'GER_PAR', 'GER', 'PAR', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'FRA_SWE', 'FRA', 'SWE', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'RSA_CAN', 'RSA', 'CAN', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'NED_MAR', 'NED', 'MAR', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'POR_CRO', 'POR', 'CRO', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'BEL_SEN', 'BEL', 'SEN', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'USA_BIH', 'USA', 'BIH', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'ESP_AUT', 'ESP', 'AUT', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'BRA_JPN', 'BRA', 'JPN', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'CIV_NOR', 'CIV', 'NOR', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'MEX_ECU', 'MEX', 'ECU', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'ENG_COD', 'ENG', 'COD', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'ARG_CPV', 'ARG', 'CPV', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'AUS_EGY', 'AUS', 'EGY', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'SUI_ALG', 'SUI', 'ALG', null, null, false, null, '{"events":[]}'::jsonb),
  ('r32', 'COL_GHA', 'COL', 'GHA', null, null, false, null, '{"events":[]}'::jsonb)
on conflict (round, match_id) do update
  set home_team = excluded.home_team,
      away_team = excluded.away_team,
      completed = excluded.completed,
      winner_team = excluded.winner_team,
      player_stats = excluded.player_stats;
