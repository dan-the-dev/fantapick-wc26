-- ============================================================
-- scenario_sf.sql — Quarti completati, Semifinali live
-- r32+r16+qf completed, sf live
-- Semifinaliste: France, Brazil, Spain, Argentina
-- ============================================================

update public.round_state set state = 'completed', updated_at = now() where round in ('r32','r16','qf');
update public.round_state set state = 'live',      updated_at = now() where round = 'sf';

-- Risultati Quarti
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('qf','qf_01','France','Brazil',1,0,true,'France',
   '{"Mbappé|France":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Griezmann|France":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Vinicius Jr.|Brazil":{"played":true,"goals":0,"assists":0,"yellow":true,"red":false,"penScored":false,"penMissed":false,"ownGoal":false}}'::jsonb),
  ('qf','qf_02','Argentina','England',2,1,true,'Argentina',
   '{"Messi|Argentina":{"played":true,"goals":1,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Lautaro Martínez|Argentina":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Kane|England":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Bellingham|England":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false}}'::jsonb),
  ('qf','qf_03','Spain','Italy',2,0,true,'Spain',
   '{"Yamal|Spain":{"played":true,"goals":1,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Olmo|Spain":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Donnarumma|Italy":{"played":true,"goals":0,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"goalsConceded":2}}'::jsonb),
  ('qf','qf_04','Germany','Portugal',1,2,true,'Portugal',
   '{"Ronaldo|Portugal":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":true,"penMissed":false,"ownGoal":false},
     "Bruno Fernandes|Portugal":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Havertz|Germany":{"played":true,"goals":1,"assists":0,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false},
     "Musiala|Germany":{"played":true,"goals":0,"assists":1,"yellow":false,"red":false,"penScored":false,"penMissed":false,"ownGoal":false}}'::jsonb)
on conflict (round, match_id) do update
  set home_score=excluded.home_score, away_score=excluded.away_score,
      completed=excluded.completed, winner_team=excluded.winner_team,
      player_stats=excluded.player_stats, updated_at=now();

-- 4 qualificate alle Semifinali
insert into public.qualified_teams (round, team_code) values
  ('sf','France'),('sf','Argentina'),('sf','Spain'),('sf','Portugal')
on conflict do nothing;

-- Draft per le Semifinali
insert into public.drafts (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, ts)
values
  ('Tifoso_Milano','sf',
   '{"name":"Deschamps","team":"France","flag":"🇫🇷","formation":"4-3-3"}',
   '[
     {"name":"Maignan","team":"France","role":"P","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Theo Hernández","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Varane","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Koundé","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ronaldo","team":"Portugal","role":"A","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Griezmann","team":"France","role":"C","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Yamal","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Mbappé|France',0,true,
   extract(epoch from now()-interval '12 minutes')*1000),
  ('DraftKing99','sf',
   '{"name":"Scaloni","team":"Argentina","flag":"🇦🇷","formation":"4-3-3"}',
   '[
     {"name":"Martínez E.|Argentina","role":"P","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Molina","team":"Argentina","role":"D","stars":3,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Tagliafico","team":"Argentina","role":"D","stars":3,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Olmo","team":"Spain","role":"A","stars":4,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"De Paul","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mac Allister","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Messi|Argentina',0,false,
   extract(epoch from now()-interval '10 minutes')*1000)
on conflict (round, nickname) do update
  set picks=excluded.picks, coach=excluded.coach, formation=excluded.formation,
      captain=excluded.captain, score=0, ct_bonus_applied=excluded.ct_bonus_applied,
      ts=excluded.ts, updated_at=now();
