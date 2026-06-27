-- ============================================================
-- scenario_final.sql — Mondiale finito, classifiche complete
-- Tutti i round completed, punteggi realistici, Perfect XI calcolabile
-- Finale: France 1-0 Argentina
-- player_stats: { events: [...] } (played null = all played)
-- ============================================================

update public.round_state set state = 'completed', updated_at = now();

-- Risultati Semifinali
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('sf','sf_01','France','Spain',2,1,true,'France',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e2","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e3","type":"assist","playerKey":"Griezmann|France","playerName":"Griezmann","team":"France","minute":null},
     {"id":"e4","type":"assist","playerKey":"Theo Hernández|France","playerName":"Theo Hernández","team":"France","minute":null},
     {"id":"e5","type":"goal","playerKey":"Yamal|Spain","playerName":"Yamal","team":"Spain","minute":null},
     {"id":"e6","type":"assist","playerKey":"Pedri|Spain","playerName":"Pedri","team":"Spain","minute":null}
   ]}'::jsonb),
  ('sf','sf_02','Argentina','Portugal',3,2,true,'Argentina',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e2","type":"pen_scored","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e3","type":"assist","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e4","type":"goal","playerKey":"Lautaro Martínez|Argentina","playerName":"Lautaro Martínez","team":"Argentina","minute":null},
     {"id":"e5","type":"assist","playerKey":"De Paul|Argentina","playerName":"De Paul","team":"Argentina","minute":null},
     {"id":"e6","type":"goal","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e7","type":"pen_scored","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e8","type":"assist","playerKey":"Bruno Fernandes|Portugal","playerName":"Bruno Fernandes","team":"Portugal","minute":null}
   ]}'::jsonb)
on conflict (round, match_id) do update
  set home_score=excluded.home_score, away_score=excluded.away_score,
      completed=excluded.completed, winner_team=excluded.winner_team,
      player_stats=excluded.player_stats, updated_at=now();

-- Risultato Finale
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('final','final_01','France','Argentina',1,0,true,'France',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e2","type":"assist","playerKey":"Griezmann|France","playerName":"Griezmann","team":"France","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Lautaro Martínez|Argentina","playerName":"Lautaro Martínez","team":"Argentina","minute":null},
     {"id":"e4","type":"yellow_card","playerKey":"Di María|Argentina","playerName":"Di María","team":"Argentina","minute":null}
   ]}'::jsonb)
on conflict (round, match_id) do update
  set home_score=excluded.home_score, away_score=excluded.away_score,
      completed=excluded.completed, winner_team=excluded.winner_team,
      player_stats=excluded.player_stats, updated_at=now();

-- Finaliste
insert into public.qualified_teams (round, team_code) values
  ('final','France'),('final','Argentina')
on conflict do nothing;

-- Draft finale con punteggi realistici e variegati
insert into public.drafts (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, ts)
values
  ('Tifoso_Milano','final',
   '{"name":"Deschamps","team":"France","flag":"🇫🇷","formation":"4-3-3"}',
   '[
     {"name":"Maignan","team":"France","role":"P","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Theo Hernández","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Varane","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Koundé","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Tagliafico","team":"Argentina","role":"D","stars":3,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":4,"finalPts":6,"isCaptain":true},
     {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":4,"flag":"🇦🇷","pts":-1.5,"finalPts":-1.5,"isCaptain":false},
     {"name":"Griezmann","team":"France","role":"C","stars":4,"flag":"🇫🇷","pts":2,"finalPts":2,"isCaptain":false},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Yamal","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Mbappé|France',10.75,true,
   extract(epoch from now()-interval '2 hours')*1000),
  ('DraftKing99','final',
   '{"name":"Scaloni","team":"Argentina","flag":"🇦🇷","formation":"4-3-3"}',
   '[
     {"name":"Maignan","team":"France","role":"P","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Molina","team":"Argentina","role":"D","stars":3,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Tagliafico","team":"Argentina","role":"D","stars":3,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":-1,"finalPts":-1.5,"isCaptain":true},
     {"name":"Ronaldo","team":"Portugal","role":"A","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":4,"flag":"🇦🇷","pts":-1.5,"finalPts":-1.5,"isCaptain":false},
     {"name":"De Paul","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Mac Allister","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Messi|Argentina',-7.0,false,
   extract(epoch from now()-interval '1 hour 55 minutes')*1000),
  ('FantaMaster','final',
   '{"name":"Guardiola","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}',
   '[
     {"name":"Maignan","team":"France","role":"P","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Theo Hernández","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Varane","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Koundé","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":1,"finalPts":1,"isCaptain":false},
     {"name":"Molina","team":"Argentina","role":"D","stars":3,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":4,"finalPts":4,"isCaptain":false},
     {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":4,"flag":"🇦🇷","pts":-1.5,"finalPts":-1.5,"isCaptain":false},
     {"name":"Griezmann","team":"France","role":"A","stars":4,"flag":"🇫🇷","pts":2,"finalPts":2,"isCaptain":false},
     {"name":"De Paul","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":-1,"finalPts":-1,"isCaptain":false},
     {"name":"Mac Allister","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":-1,"finalPts":-3,"isCaptain":true},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Mac Allister|Argentina',3.5,false,
   extract(epoch from now()-interval '1 hour 50 minutes')*1000)
on conflict (round, nickname) do update
  set picks=excluded.picks, coach=excluded.coach, formation=excluded.formation,
      captain=excluded.captain, score=excluded.score,
      ct_bonus_applied=excluded.ct_bonus_applied, ts=excluded.ts, updated_at=now();
