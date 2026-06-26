-- ============================================================
-- scenario_final.sql — Mondiale finito, classifiche complete
-- Tutti i round completed, punteggi realistici, Perfect XI calcolabile
-- Finale: France 1-0 Argentina
-- ============================================================

update public.round_state set state = 'completed', updated_at = now();

-- Risultati Semifinali
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('sf','sf_01','France','Spain',2,1,true,'France',
   '{"Mbappé|France":{"played":true,"goals":2,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Griezmann|France":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Theo Hernández|France":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Yamal|Spain":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Pedri|Spain":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false}}'::jsonb),
  ('sf','sf_02','Argentina','Portugal',3,2,true,'Argentina',
   '{"Messi|Argentina":{"played":true,"goals":2,"assists":1,"yellow":false,"red":false,"penScored":true,"penMissed":false,"ownGoal":false},
     "Lautaro Martínez|Argentina":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Ronaldo|Portugal":{"played":true,"goals":2,"assists":0,"yellow":false,"red":false,"penScored":true,"penMissed":false,"ownGoal":false},
     "Bruno Fernandes|Portugal":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "De Paul|Argentina":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false}}'::jsonb)
on conflict (round, match_id) do update
  set home_score=excluded.home_score, away_score=excluded.away_score,
      completed=excluded.completed, winner_team=excluded.winner_team,
      player_stats=excluded.player_stats, updated_at=now();

-- Risultato Finale
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('final','final_01','France','Argentina',1,0,true,'France',
   '{"Mbappé|France":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Griezmann|France":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Maignan|France":{"played":true,"goals":0,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false,"goalsConceded":0},
     "Varane|France":{"played":true,"goals":0,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Koundé|France":{"played":true,"goals":0,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Theo Hernández|France":{"played":true,"goals":0,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Messi|Argentina":{"played":true,"goals":0,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Lautaro Martínez|Argentina":{"played":true,"goals":0,"assists":0,"yellow":true,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Di María|Argentina":{"played":true,"goals":0,"assists":0,"yellow":true,"red":false,"penScored":false,"penMissed":false,"ownGoal":false}}'::jsonb)
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
