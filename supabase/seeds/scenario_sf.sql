-- ============================================================
-- scenario_sf.sql — Quarti completati, Semifinali live
-- r32+r16+qf completed, sf live
-- Semifinaliste: France, Brazil, Spain, Argentina
-- player_stats: { events: [...] } (played null = all played)
-- ============================================================

update public.round_state set state = 'completed', updated_at = now() where round in ('r32','r16','qf');
update public.round_state set state = 'live',      updated_at = now() where round = 'sf';

-- Risultati Quarti
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('qf','qf_01','France','Brazil',1,0,true,'France',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e2","type":"assist","playerKey":"Griezmann|France","playerName":"Griezmann","team":"France","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Vinicius Jr.|Brazil","playerName":"Vinicius Jr.","team":"Brazil","minute":null}
   ]}'::jsonb),
  ('qf','qf_02','Argentina','England',2,1,true,'Argentina',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e2","type":"assist","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e3","type":"goal","playerKey":"Lautaro Martínez|Argentina","playerName":"Lautaro Martínez","team":"Argentina","minute":null},
     {"id":"e4","type":"goal","playerKey":"Kane|England","playerName":"Kane","team":"England","minute":null},
     {"id":"e5","type":"assist","playerKey":"Bellingham|England","playerName":"Bellingham","team":"England","minute":null}
   ]}'::jsonb),
  ('qf','qf_03','Spain','Italy',2,0,true,'Spain',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Yamal|Spain","playerName":"Yamal","team":"Spain","minute":null},
     {"id":"e2","type":"assist","playerKey":"Yamal|Spain","playerName":"Yamal","team":"Spain","minute":null},
     {"id":"e3","type":"goal","playerKey":"Olmo|Spain","playerName":"Olmo","team":"Spain","minute":null}
   ]}'::jsonb),
  ('qf','qf_04','Germany','Portugal',1,2,true,'Portugal',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e2","type":"pen_scored","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e3","type":"goal","playerKey":"Bruno Fernandes|Portugal","playerName":"Bruno Fernandes","team":"Portugal","minute":null},
     {"id":"e4","type":"goal","playerKey":"Havertz|Germany","playerName":"Havertz","team":"Germany","minute":null},
     {"id":"e5","type":"assist","playerKey":"Musiala|Germany","playerName":"Musiala","team":"Germany","minute":null}
   ]}'::jsonb)
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
     {"name":"Martínez E.","team":"Argentina","role":"P","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
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
