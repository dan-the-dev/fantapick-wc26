-- ============================================================
-- scenario_qf.sql — Ottavi completati, Quarti live
-- r32 completed, r16 completed, qf live
-- Quarti: France-Brazil, Argentina-England, Spain-Germany, Portugal-Italy
-- player_stats: { events: [...] } (played null = all played)
-- ============================================================

update public.round_state set state = 'completed', updated_at = now() where round in ('r32','r16');
update public.round_state set state = 'live',      updated_at = now() where round = 'qf';

-- Eredita i risultati r32 da scenario_r16 (già inseriti da _base + r16 seed)
-- Risultati Ottavi (r16) — 8 partite
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('r16','r16_01','France','Japan',2,0,true,'France',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e2","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e3","type":"assist","playerKey":"Griezmann|France","playerName":"Griezmann","team":"France","minute":null},
     {"id":"e4","type":"assist","playerKey":"Theo Hernández|France","playerName":"Theo Hernández","team":"France","minute":null}
   ]}'::jsonb),
  ('r16','r16_02','Brazil','Morocco',3,1,true,'Brazil',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Vinicius Jr.|Brazil","playerName":"Vinicius Jr.","team":"Brazil","minute":null},
     {"id":"e2","type":"assist","playerKey":"Vinicius Jr.|Brazil","playerName":"Vinicius Jr.","team":"Brazil","minute":null},
     {"id":"e3","type":"goal","playerKey":"Rodrygo|Brazil","playerName":"Rodrygo","team":"Brazil","minute":null},
     {"id":"e4","type":"goal","playerKey":"Raphinha|Brazil","playerName":"Raphinha","team":"Brazil","minute":null},
     {"id":"e5","type":"goal","playerKey":"Ziyech|Morocco","playerName":"Ziyech","team":"Morocco","minute":null}
   ]}'::jsonb),
  ('r16','r16_03','Argentina','Poland',2,0,true,'Argentina',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e2","type":"assist","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e3","type":"goal","playerKey":"Lautaro Martínez|Argentina","playerName":"Lautaro Martínez","team":"Argentina","minute":null},
     {"id":"e4","type":"yellow_card","playerKey":"Lewandowski|Poland","playerName":"Lewandowski","team":"Poland","minute":null}
   ]}'::jsonb),
  ('r16','r16_04','England','Belgium',1,0,true,'England',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Kane|England","playerName":"Kane","team":"England","minute":null},
     {"id":"e2","type":"assist","playerKey":"Bellingham|England","playerName":"Bellingham","team":"England","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"De Bruyne|Belgium","playerName":"De Bruyne","team":"Belgium","minute":null}
   ]}'::jsonb),
  ('r16','r16_05','Spain','Canada',3,0,true,'Spain',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Yamal|Spain","playerName":"Yamal","team":"Spain","minute":null},
     {"id":"e2","type":"assist","playerKey":"Yamal|Spain","playerName":"Yamal","team":"Spain","minute":null},
     {"id":"e3","type":"goal","playerKey":"Olmo|Spain","playerName":"Olmo","team":"Spain","minute":null},
     {"id":"e4","type":"goal","playerKey":"Morata|Spain","playerName":"Morata","team":"Spain","minute":null},
     {"id":"e5","type":"assist","playerKey":"Pedri|Spain","playerName":"Pedri","team":"Spain","minute":null}
   ]}'::jsonb),
  ('r16','r16_06','Germany','Uruguay',2,1,true,'Germany',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Musiala|Germany","playerName":"Musiala","team":"Germany","minute":null},
     {"id":"e2","type":"goal","playerKey":"Wirtz|Germany","playerName":"Wirtz","team":"Germany","minute":null},
     {"id":"e3","type":"goal","playerKey":"Darwin Núñez|Uruguay","playerName":"Darwin Núñez","team":"Uruguay","minute":null}
   ]}'::jsonb),
  ('r16','r16_07','Portugal','USA',2,0,true,'Portugal',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e2","type":"goal","playerKey":"Bruno Fernandes|Portugal","playerName":"Bruno Fernandes","team":"Portugal","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Pulisic|USA","playerName":"Pulisic","team":"USA","minute":null}
   ]}'::jsonb),
  ('r16','r16_08','Netherlands','Italy',1,2,true,'Italy',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Barella|Italy","playerName":"Barella","team":"Italy","minute":null},
     {"id":"e2","type":"assist","playerKey":"Barella|Italy","playerName":"Barella","team":"Italy","minute":null},
     {"id":"e3","type":"goal","playerKey":"Retegui|Italy","playerName":"Retegui","team":"Italy","minute":null},
     {"id":"e4","type":"goal","playerKey":"Depay|Netherlands","playerName":"Depay","team":"Netherlands","minute":null}
   ]}'::jsonb)
on conflict (round, match_id) do update
  set home_score=excluded.home_score, away_score=excluded.away_score,
      completed=excluded.completed, winner_team=excluded.winner_team,
      player_stats=excluded.player_stats, updated_at=now();

-- 8 qualificate ai Quarti
insert into public.qualified_teams (round, team_code) values
  ('qf','France'),('qf','Brazil'),('qf','Argentina'),('qf','England'),
  ('qf','Spain'), ('qf','Germany'),('qf','Portugal'), ('qf','Italy')
on conflict do nothing;

-- Draft per i Quarti
insert into public.drafts (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, ts)
values
  ('Tifoso_Milano','qf',
   '{"name":"Spalletti","team":"Italy","flag":"🇮🇹","formation":"4-3-3"}',
   '[
     {"name":"Donnarumma","team":"Italy","role":"P","stars":5,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bastoni","team":"Italy","role":"D","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Theo Hernández","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Yamal","team":"Spain","role":"A","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bellingham","team":"England","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Musiala","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Barella","team":"Italy","role":"C","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Mbappé|France',0,true,
   extract(epoch from now()-interval '9 minutes')*1000),
  ('DraftKing99','qf',
   '{"name":"Ancelotti","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}',
   '[
     {"name":"Neuer","team":"Germany","role":"P","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Koundé","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Varane","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Acerbi","team":"Italy","role":"D","stars":3,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Trippier","team":"England","role":"D","stars":3,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ronaldo","team":"Portugal","role":"A","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Kane","team":"England","role":"A","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kroos","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Wirtz","team":"Germany","role":"C","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"','Ronaldo|Portugal',0,false,
   extract(epoch from now()-interval '7 minutes')*1000)
on conflict (round, nickname) do update
  set picks=excluded.picks, coach=excluded.coach, formation=excluded.formation,
      captain=excluded.captain, score=0, ct_bonus_applied=excluded.ct_bonus_applied,
      ts=excluded.ts, updated_at=now();
