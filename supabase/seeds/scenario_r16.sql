-- ============================================================
-- scenario_r16.sql — Sedicesimi completati, Ottavi live
-- player_stats: { events: [...], played: null (= all played) }
-- ============================================================

update public.round_state set state = 'completed', updated_at = now() where round = 'r32';
update public.round_state set state = 'live',      updated_at = now() where round = 'r16';

-- ── Risultati Sedicesimi ─────────────────────────────────────
insert into public.match_data
  (round, match_id, home_team, away_team, home_score, away_score, completed, winner_team, player_stats)
values
  ('r32','r32_01','Brazil','Egypt',2,0,true,'Brazil',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Vinicius Jr.|Brazil","playerName":"Vinicius Jr.","team":"Brazil","minute":null},
     {"id":"e2","type":"goal","playerKey":"Rodrygo|Brazil","playerName":"Rodrygo","team":"Brazil","minute":null},
     {"id":"e3","type":"assist","playerKey":"Bruno Guimarães|Brazil","playerName":"Bruno Guimarães","team":"Brazil","minute":null},
     {"id":"e4","type":"assist","playerKey":"Lucas Paquetá|Brazil","playerName":"Lucas Paquetá","team":"Brazil","minute":null},
     {"id":"e5","type":"yellow_card","playerKey":"Casemiro|Brazil","playerName":"Casemiro","team":"Brazil","minute":null},
     {"id":"e6","type":"yellow_card","playerKey":"Salah|Egypt","playerName":"Salah","team":"Egypt","minute":null}
   ]}'::jsonb),
  ('r32','r32_02','Argentina','Costa Rica',3,1,true,'Argentina',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e2","type":"goal","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e3","type":"assist","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e4","type":"pen_scored","playerKey":"Messi|Argentina","playerName":"Messi","team":"Argentina","minute":null},
     {"id":"e5","type":"goal","playerKey":"Lautaro Martínez|Argentina","playerName":"Lautaro Martínez","team":"Argentina","minute":null},
     {"id":"e6","type":"assist","playerKey":"Di María|Argentina","playerName":"Di María","team":"Argentina","minute":null},
     {"id":"e7","type":"yellow_card","playerKey":"Paredes|Argentina","playerName":"Paredes","team":"Argentina","minute":null},
     {"id":"e8","type":"goal","playerKey":"Campbell|Costa Rica","playerName":"Campbell","team":"Costa Rica","minute":null},
     {"id":"e9","type":"assist","playerKey":"Bryan Ruiz|Costa Rica","playerName":"Bryan Ruiz","team":"Costa Rica","minute":null},
     {"id":"e10","type":"yellow_card","playerKey":"Waston|Costa Rica","playerName":"Waston","team":"Costa Rica","minute":null}
   ]}'::jsonb),
  ('r32','r32_03','France','Nigeria',2,1,true,'France',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Mbappé|France","playerName":"Mbappé","team":"France","minute":null},
     {"id":"e2","type":"goal","playerKey":"Giroud|France","playerName":"Giroud","team":"France","minute":null},
     {"id":"e3","type":"assist","playerKey":"Dembélé|France","playerName":"Dembélé","team":"France","minute":null},
     {"id":"e4","type":"assist","playerKey":"Griezmann|France","playerName":"Griezmann","team":"France","minute":null},
     {"id":"e5","type":"yellow_card","playerKey":"Koundé|France","playerName":"Koundé","team":"France","minute":null},
     {"id":"e6","type":"goal","playerKey":"Osimhen|Nigeria","playerName":"Osimhen","team":"Nigeria","minute":null},
     {"id":"e7","type":"assist","playerKey":"Lookman|Nigeria","playerName":"Lookman","team":"Nigeria","minute":null},
     {"id":"e8","type":"yellow_card","playerKey":"Collins|Nigeria","playerName":"Collins","team":"Nigeria","minute":null}
   ]}'::jsonb),
  ('r32','r32_04','England','Senegal',2,0,true,'England',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Bellingham|England","playerName":"Bellingham","team":"England","minute":null},
     {"id":"e2","type":"goal","playerKey":"Kane|England","playerName":"Kane","team":"England","minute":null},
     {"id":"e3","type":"assist","playerKey":"Foden|England","playerName":"Foden","team":"England","minute":null},
     {"id":"e4","type":"assist","playerKey":"Saka|England","playerName":"Saka","team":"England","minute":null},
     {"id":"e5","type":"yellow_card","playerKey":"Trippier|England","playerName":"Trippier","team":"England","minute":null},
     {"id":"e6","type":"yellow_card","playerKey":"Guèye|Senegal","playerName":"Guèye","team":"Senegal","minute":null}
   ]}'::jsonb),
  ('r32','r32_05','Spain','Serbia',3,0,true,'Spain',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Pedri|Spain","playerName":"Pedri","team":"Spain","minute":null},
     {"id":"e2","type":"assist","playerKey":"Pedri|Spain","playerName":"Pedri","team":"Spain","minute":null},
     {"id":"e3","type":"goal","playerKey":"Yamal|Spain","playerName":"Yamal","team":"Spain","minute":null},
     {"id":"e4","type":"goal","playerKey":"Olmo|Spain","playerName":"Olmo","team":"Spain","minute":null},
     {"id":"e5","type":"assist","playerKey":"Gavi|Spain","playerName":"Gavi","team":"Spain","minute":null},
     {"id":"e6","type":"yellow_card","playerKey":"Gavi|Spain","playerName":"Gavi","team":"Spain","minute":null},
     {"id":"e7","type":"assist","playerKey":"Morata|Spain","playerName":"Morata","team":"Spain","minute":null},
     {"id":"e8","type":"yellow_card","playerKey":"Milinković-Savić|Serbia","playerName":"Milinković-Savić","team":"Serbia","minute":null},
     {"id":"e9","type":"red_card","playerKey":"Mitrović|Serbia","playerName":"Mitrović","team":"Serbia","minute":null}
   ]}'::jsonb),
  ('r32','r32_06','Germany','Chile',3,1,true,'Germany',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Wirtz|Germany","playerName":"Wirtz","team":"Germany","minute":null},
     {"id":"e2","type":"goal","playerKey":"Havertz|Germany","playerName":"Havertz","team":"Germany","minute":null},
     {"id":"e3","type":"goal","playerKey":"Füllkrug|Germany","playerName":"Füllkrug","team":"Germany","minute":null},
     {"id":"e4","type":"assist","playerKey":"Musiala|Germany","playerName":"Musiala","team":"Germany","minute":null},
     {"id":"e5","type":"assist","playerKey":"Gnabry|Germany","playerName":"Gnabry","team":"Germany","minute":null},
     {"id":"e6","type":"assist","playerKey":"Kroos|Germany","playerName":"Kroos","team":"Germany","minute":null},
     {"id":"e7","type":"goal","playerKey":"Brereton Díaz|Chile","playerName":"Brereton Díaz","team":"Chile","minute":null},
     {"id":"e8","type":"assist","playerKey":"Alexis Sánchez|Chile","playerName":"Alexis Sánchez","team":"Chile","minute":null},
     {"id":"e9","type":"yellow_card","playerKey":"Medel|Chile","playerName":"Medel","team":"Chile","minute":null},
     {"id":"e10","type":"yellow_card","playerKey":"Vidal|Chile","playerName":"Vidal","team":"Chile","minute":null}
   ]}'::jsonb),
  ('r32','r32_07','Portugal','Colombia',4,1,true,'Portugal',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e2","type":"goal","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e3","type":"goal","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e4","type":"pen_scored","playerKey":"Ronaldo|Portugal","playerName":"Ronaldo","team":"Portugal","minute":null},
     {"id":"e5","type":"goal","playerKey":"Bruno Fernandes|Portugal","playerName":"Bruno Fernandes","team":"Portugal","minute":null},
     {"id":"e6","type":"assist","playerKey":"Cancelo|Portugal","playerName":"Cancelo","team":"Portugal","minute":null},
     {"id":"e7","type":"assist","playerKey":"Rúben Neves|Portugal","playerName":"Rúben Neves","team":"Portugal","minute":null},
     {"id":"e8","type":"assist","playerKey":"Diogo Jota|Portugal","playerName":"Diogo Jota","team":"Portugal","minute":null},
     {"id":"e9","type":"yellow_card","playerKey":"Rúben Dias|Portugal","playerName":"Rúben Dias","team":"Portugal","minute":null},
     {"id":"e10","type":"goal","playerKey":"Luis Díaz|Colombia","playerName":"Luis Díaz","team":"Colombia","minute":null},
     {"id":"e11","type":"assist","playerKey":"J. Rodríguez|Colombia","playerName":"J. Rodríguez","team":"Colombia","minute":null},
     {"id":"e12","type":"yellow_card","playerKey":"D. Sánchez|Colombia","playerName":"D. Sánchez","team":"Colombia","minute":null}
   ]}'::jsonb),
  ('r32','r32_08','Netherlands','Ecuador',1,0,true,'Netherlands',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Dumfries|Netherlands","playerName":"Dumfries","team":"Netherlands","minute":null},
     {"id":"e2","type":"assist","playerKey":"Depay|Netherlands","playerName":"Depay","team":"Netherlands","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"de Vrij|Netherlands","playerName":"de Vrij","team":"Netherlands","minute":null},
     {"id":"e4","type":"yellow_card","playerKey":"Caicedo|Ecuador","playerName":"Caicedo","team":"Ecuador","minute":null}
   ]}'::jsonb),
  ('r32','r32_09','Italy','Switzerland',2,1,true,'Italy',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Barella|Italy","playerName":"Barella","team":"Italy","minute":null},
     {"id":"e2","type":"goal","playerKey":"Retegui|Italy","playerName":"Retegui","team":"Italy","minute":null},
     {"id":"e3","type":"assist","playerKey":"Dimarco|Italy","playerName":"Dimarco","team":"Italy","minute":null},
     {"id":"e4","type":"assist","playerKey":"Frattesi|Italy","playerName":"Frattesi","team":"Italy","minute":null},
     {"id":"e5","type":"yellow_card","playerKey":"Acerbi|Italy","playerName":"Acerbi","team":"Italy","minute":null},
     {"id":"e6","type":"goal","playerKey":"Embolo|Switzerland","playerName":"Embolo","team":"Switzerland","minute":null},
     {"id":"e7","type":"assist","playerKey":"Xhaka|Switzerland","playerName":"Xhaka","team":"Switzerland","minute":null},
     {"id":"e8","type":"yellow_card","playerKey":"Xhaka|Switzerland","playerName":"Xhaka","team":"Switzerland","minute":null},
     {"id":"e9","type":"pen_missed","playerKey":"Shaqiri|Switzerland","playerName":"Shaqiri","team":"Switzerland","minute":null}
   ]}'::jsonb),
  ('r32','r32_10','Belgium','South Korea',3,2,true,'Belgium',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"De Bruyne|Belgium","playerName":"De Bruyne","team":"Belgium","minute":null},
     {"id":"e2","type":"goal","playerKey":"De Bruyne|Belgium","playerName":"De Bruyne","team":"Belgium","minute":null},
     {"id":"e3","type":"goal","playerKey":"Lukaku|Belgium","playerName":"Lukaku","team":"Belgium","minute":null},
     {"id":"e4","type":"pen_scored","playerKey":"Lukaku|Belgium","playerName":"Lukaku","team":"Belgium","minute":null},
     {"id":"e5","type":"assist","playerKey":"Doku|Belgium","playerName":"Doku","team":"Belgium","minute":null},
     {"id":"e6","type":"assist","playerKey":"Tielemans|Belgium","playerName":"Tielemans","team":"Belgium","minute":null},
     {"id":"e7","type":"yellow_card","playerKey":"Witsel|Belgium","playerName":"Witsel","team":"Belgium","minute":null},
     {"id":"e8","type":"goal","playerKey":"Son|South Korea","playerName":"Son","team":"South Korea","minute":null},
     {"id":"e9","type":"goal","playerKey":"Son|South Korea","playerName":"Son","team":"South Korea","minute":null},
     {"id":"e10","type":"pen_scored","playerKey":"Son|South Korea","playerName":"Son","team":"South Korea","minute":null},
     {"id":"e11","type":"assist","playerKey":"Hwang Hee-chan|South Korea","playerName":"Hwang Hee-chan","team":"South Korea","minute":null},
     {"id":"e12","type":"yellow_card","playerKey":"Kim Min-Jae|South Korea","playerName":"Kim Min-Jae","team":"South Korea","minute":null}
   ]}'::jsonb),
  ('r32','r32_11','Croatia','Morocco',0,1,true,'Morocco',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Ziyech|Morocco","playerName":"Ziyech","team":"Morocco","minute":null},
     {"id":"e2","type":"assist","playerKey":"Hakimi|Morocco","playerName":"Hakimi","team":"Morocco","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Modrić|Croatia","playerName":"Modrić","team":"Croatia","minute":null},
     {"id":"e4","type":"yellow_card","playerKey":"Brozović|Croatia","playerName":"Brozović","team":"Croatia","minute":null}
   ]}'::jsonb),
  ('r32','r32_12','Uruguay','Austria',2,0,true,'Uruguay',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Darwin Núñez|Uruguay","playerName":"Darwin Núñez","team":"Uruguay","minute":null},
     {"id":"e2","type":"goal","playerKey":"Valverde|Uruguay","playerName":"Valverde","team":"Uruguay","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Valverde|Uruguay","playerName":"Valverde","team":"Uruguay","minute":null},
     {"id":"e4","type":"assist","playerKey":"L. Suárez|Uruguay","playerName":"L. Suárez","team":"Uruguay","minute":null},
     {"id":"e5","type":"assist","playerKey":"Bentancur|Uruguay","playerName":"Bentancur","team":"Uruguay","minute":null},
     {"id":"e6","type":"yellow_card","playerKey":"Laimer|Austria","playerName":"Laimer","team":"Austria","minute":null}
   ]}'::jsonb),
  ('r32','r32_13','Mexico','Poland',1,2,true,'Poland',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Lewandowski|Poland","playerName":"Lewandowski","team":"Poland","minute":null},
     {"id":"e2","type":"goal","playerKey":"Lewandowski|Poland","playerName":"Lewandowski","team":"Poland","minute":null},
     {"id":"e3","type":"assist","playerKey":"Zieliński|Poland","playerName":"Zieliński","team":"Poland","minute":null},
     {"id":"e4","type":"assist","playerKey":"Szymański|Poland","playerName":"Szymański","team":"Poland","minute":null},
     {"id":"e5","type":"yellow_card","playerKey":"Krychowiak|Poland","playerName":"Krychowiak","team":"Poland","minute":null},
     {"id":"e6","type":"goal","playerKey":"H. Lozano|Mexico","playerName":"H. Lozano","team":"Mexico","minute":null},
     {"id":"e7","type":"assist","playerKey":"Pineda|Mexico","playerName":"Pineda","team":"Mexico","minute":null},
     {"id":"e8","type":"yellow_card","playerKey":"Edson Álvarez|Mexico","playerName":"Edson Álvarez","team":"Mexico","minute":null}
   ]}'::jsonb),
  ('r32','r32_14','Denmark','Japan',1,1,true,'Japan',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Eriksen|Denmark","playerName":"Eriksen","team":"Denmark","minute":null},
     {"id":"e2","type":"assist","playerKey":"Braithwaite|Denmark","playerName":"Braithwaite","team":"Denmark","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Andersen|Denmark","playerName":"Andersen","team":"Denmark","minute":null},
     {"id":"e4","type":"goal","playerKey":"Mitoma|Japan","playerName":"Mitoma","team":"Japan","minute":null},
     {"id":"e5","type":"assist","playerKey":"Kubo|Japan","playerName":"Kubo","team":"Japan","minute":null},
     {"id":"e6","type":"yellow_card","playerKey":"Wataru Endō|Japan","playerName":"Wataru Endō","team":"Japan","minute":null}
   ]}'::jsonb),
  ('r32','r32_15','Sweden','USA',0,1,true,'USA',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Pulisic|USA","playerName":"Pulisic","team":"USA","minute":null},
     {"id":"e2","type":"assist","playerKey":"Reyna|USA","playerName":"Reyna","team":"USA","minute":null},
     {"id":"e3","type":"yellow_card","playerKey":"Adams|USA","playerName":"Adams","team":"USA","minute":null},
     {"id":"e4","type":"yellow_card","playerKey":"Forsberg|Sweden","playerName":"Forsberg","team":"Sweden","minute":null}
   ]}'::jsonb),
  ('r32','r32_16','Wales','Canada',1,2,true,'Canada',
   '{"events":[
     {"id":"e1","type":"goal","playerKey":"Davies|Canada","playerName":"Davies","team":"Canada","minute":null},
     {"id":"e2","type":"goal","playerKey":"David|Canada","playerName":"David","team":"Canada","minute":null},
     {"id":"e3","type":"assist","playerKey":"Buchanan|Canada","playerName":"Buchanan","team":"Canada","minute":null},
     {"id":"e4","type":"assist","playerKey":"Eustáquio|Canada","playerName":"Eustáquio","team":"Canada","minute":null},
     {"id":"e5","type":"yellow_card","playerKey":"Vitória|Canada","playerName":"Vitória","team":"Canada","minute":null},
     {"id":"e6","type":"goal","playerKey":"Bale|Wales","playerName":"Bale","team":"Wales","minute":null},
     {"id":"e7","type":"assist","playerKey":"Dan James|Wales","playerName":"Dan James","team":"Wales","minute":null},
     {"id":"e8","type":"yellow_card","playerKey":"Ramsey|Wales","playerName":"Ramsey","team":"Wales","minute":null}
   ]}'::jsonb)
on conflict (round, match_id) do update
  set home_score = excluded.home_score, away_score = excluded.away_score,
      completed = excluded.completed, winner_team = excluded.winner_team,
      player_stats = excluded.player_stats, updated_at = now();

-- ── 16 qualificate agli Ottavi ───────────────────────────────
insert into public.qualified_teams (round, team_code) values
  ('r16', 'Brazil'), ('r16', 'Argentina'), ('r16', 'France'), ('r16', 'England'),
  ('r16', 'Spain'),  ('r16', 'Germany'),   ('r16', 'Portugal'),('r16', 'Netherlands'),
  ('r16', 'Italy'),  ('r16', 'Belgium'),   ('r16', 'Morocco'), ('r16', 'Uruguay'),
  ('r16', 'Poland'), ('r16', 'Japan'),     ('r16', 'USA'),     ('r16', 'Canada')
on conflict do nothing;

-- ── Draft di esempio per gli Ottavi ─────────────────────────
insert into public.drafts
  (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, ts)
values
  ('Tifoso_Milano', 'r16',
   '{"name":"Ancelotti","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}',
   '[
     {"name":"Donnarumma","team":"Italy","role":"P","stars":5,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Hakimi","team":"Morocco","role":"D","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Davies","team":"Canada","role":"D","stars":4,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Vinicius Jr.","team":"Brazil","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lewandowski","team":"Poland","role":"A","stars":5,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"De Bruyne","team":"Belgium","role":"C","stars":5,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bellingham","team":"England","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"', 'Mbappé|France', 0, false,
   extract(epoch from now() - interval '6 minutes') * 1000),
  ('DraftKing99', 'r16',
   '{"name":"Guardiola","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}',
   '[
     {"name":"Neuer","team":"Germany","role":"P","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Koundé","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Varane","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"de Vrij","team":"Netherlands","role":"D","stars":3,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Trippier","team":"England","role":"D","stars":3,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ronaldo","team":"Portugal","role":"A","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Kane","team":"England","role":"A","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kroos","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Musiala","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Barella","team":"Italy","role":"C","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false}
   ]',
   '"4-3-3"', 'Ronaldo|Portugal', 0, false,
   extract(epoch from now() - interval '4 minutes') * 1000)
on conflict (round, nickname) do update
  set picks = excluded.picks, coach = excluded.coach, formation = excluded.formation,
      captain = excluded.captain, score = 0, ct_bonus_applied = false,
      ts = excluded.ts, updated_at = now();
