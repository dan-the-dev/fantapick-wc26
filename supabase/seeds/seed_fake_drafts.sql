-- ============================================================
-- seed_fake_drafts.sql — 12 draft casuali per test classifica
-- Giocatori reali da squads-complete.json, punteggi variegati
-- Usage:
--   make seed-fake-drafts               (local Supabase)
--   make seed-fake-drafts-prod          (production — richiede PROD_DB_URL)
-- Da admin UI: tab Impostazioni → "Inserisci draft di test" (DEV_MODE)
-- ============================================================

\set round r32

-- Cancella draft esistenti per il round target
delete from public.drafts where round = :'round';

-- Inserisci 12 draft con punteggi distribuiti:
--   2 top    (18-25 pts) — TifosoBR, Calcio2026
--   4 medi   (10-17 pts) — ScudettoMio, ForzaAzzurri, GoalMachine, TrequartistaFC
--   4 bassi  ( 3- 9 pts) — GoldenBoot26, WCFan99, SuperCoppa, Mister_X
--   2 sfort. ( 0- 2 pts) — UltrasTifoso, BallondOr26
insert into public.drafts
  (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, ts)
values
  ('TifosoBR', :'round',
   '{"name":"Néstor Lorenzo","team":"Colombia","flag":"🇨🇴","formation":"4-5-1"}'::jsonb,
   '[
     {"name":"Dmitrović","team":"Serbia","role":"P","stars":3,"flag":"🇷🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":false,"isCaptain":false},
     {"name":"Alexander-Arnold","team":"England","role":"D","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Yoshida","team":"Japan","role":"D","stars":4,"flag":"🇯🇵","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kim Young-gwon","team":"South Korea","role":"D","stars":3,"flag":"🇰🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Wataru Endō","team":"Japan","role":"C","stars":4,"flag":"🇯🇵","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Guèye","team":"Senegal","role":"C","stars":4,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Buchanan","team":"Canada","role":"C","stars":4,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"David","team":"Canada","role":"A","stars":5,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"En-Nesyri","team":"Morocco","role":"A","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Córdoba","team":"Colombia","role":"A","stars":3,"flag":"🇨🇴","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-4-3"', 'Alexander-Arnold|England', 24, false,
   extract(epoch from now()-interval '6 hours')::bigint * 1000),

  ('Calcio2026', :'round',
   '{"name":"Jesse Marsch","team":"Canada","flag":"🇨🇦","formation":"3-5-2"}'::jsonb,
   '[
     {"name":"Schmeichel","team":"Denmark","role":"P","stars":4,"flag":"🇩🇰","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kim Min-Jae","team":"South Korea","role":"D","stars":5,"flag":"🇰🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cáceres","team":"Uruguay","role":"D","stars":3,"flag":"🇺🇾","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Dumfries","team":"Netherlands","role":"D","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bruno Guimarães","team":"Brazil","role":"C","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Zieliński","team":"Poland","role":"C","stars":5,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Guèye","team":"Senegal","role":"C","stars":4,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kovačić","team":"Croatia","role":"C","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Griezmann","team":"France","role":"C","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Gnabry","team":"Germany","role":"A","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Minamino","team":"Japan","role":"A","stars":4,"flag":"🇯🇵","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"3-5-2"', 'Gnabry|Germany', 21, false,
   extract(epoch from now()-interval '5 hours 30 minutes')::bigint * 1000),

  ('ScudettoMio', :'round',
   '{"name":"Ralf Rangnick","team":"Austria","flag":"🇦🇹","formation":"4-5-1"}'::jsonb,
   '[
     {"name":"Lloris","team":"France","role":"P","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"T. Hernández","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Castagne","team":"Belgium","role":"D","stars":3,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Veljković","team":"Serbia","role":"D","stars":3,"flag":"🇷🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Scalvini","team":"Italy","role":"D","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Paredes","team":"Argentina","role":"C","stars":3,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Camavinga","team":"France","role":"C","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Barella","team":"Italy","role":"C","stars":5,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Mertens","team":"Belgium","role":"A","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Giroud","team":"France","role":"A","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"En-Nesyri","team":"Morocco","role":"A","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-3-3"', 'Barella|Italy', 17, false,
   extract(epoch from now()-interval '5 hours')::bigint * 1000),

  ('ForzaAzzurri', :'round',
   '{"name":"Domenico Tedesco","team":"Belgium","flag":"🇧🇪","formation":"4-3-3"}'::jsonb,
   '[
     {"name":"Diogo Costa","team":"Portugal","role":"P","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Saïss","team":"Morocco","role":"D","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"N. Molina","team":"Argentina","role":"D","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kim Jin-su","team":"South Korea","role":"D","stars":3,"flag":"🇰🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ilić","team":"Serbia","role":"C","stars":3,"flag":"🇷🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Plata","team":"Ecuador","role":"C","stars":3,"flag":"🇪🇨","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kamada","team":"Japan","role":"C","stars":4,"flag":"🇯🇵","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Valverde","team":"Uruguay","role":"C","stars":5,"flag":"🇺🇾","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Gnabry","team":"Germany","role":"A","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-4-3"', 'Mbappé|France', 15, false,
   extract(epoch from now()-interval '4 hours 30 minutes')::bigint * 1000),

  ('GoalMachine', :'round',
   '{"name":"Murat Yakin","team":"Switzerland","flag":"🇨🇭","formation":"4-5-1"}'::jsonb,
   '[
     {"name":"Kobel","team":"Switzerland","role":"P","stars":4,"flag":"🇨🇭","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Schlotterbeck","team":"Germany","role":"D","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Torres","team":"Ecuador","role":"D","stars":3,"flag":"🇪🇨","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Aguerd","team":"Morocco","role":"D","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Tsimikas","team":"Greece","role":"D","stars":3,"flag":"🇬🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Szymański","team":"Poland","role":"C","stars":4,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Klaassen","team":"Netherlands","role":"C","stars":3,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Trezeguet","team":"Egypt","role":"C","stars":3,"flag":"🇪🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Grosicki","team":"Poland","role":"C","stars":3,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Immobile","team":"Italy","role":"A","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lewandowski","team":"Poland","role":"A","stars":5,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-4-2"', 'Aguerd|Morocco', 13, false,
   extract(epoch from now()-interval '4 hours')::bigint * 1000),

  ('TrequartistaFC', :'round',
   '{"name":"Ronald Koeman","team":"Netherlands","flag":"🇳🇱","formation":"4-3-3"}'::jsonb,
   '[
     {"name":"Tagnaouti","team":"Morocco","role":"P","stars":3,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Adekugbe","team":"Canada","role":"D","stars":3,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Paulo Díaz","team":"Chile","role":"D","stars":3,"flag":"🇨🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Shaqiri","team":"Switzerland","role":"C","stars":4,"flag":"🇨🇭","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bruno Fernandes","team":"Portugal","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Sabiri","team":"Morocco","role":"C","stars":3,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Onana","team":"Belgium","role":"C","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Son","team":"South Korea","role":"A","stars":5,"flag":"🇰🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cornelius","team":"Denmark","role":"A","stars":3,"flag":"🇩🇰","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pellé","team":"China","role":"A","stars":3,"flag":"🇨🇳","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"3-4-3"', 'Bruno Fernandes|Portugal', 11, false,
   extract(epoch from now()-interval '3 hours 30 minutes')::bigint * 1000),

  ('GoldenBoot26', :'round',
   '{"name":"Aliou Cissé","team":"Senegal","flag":"🇸🇳","formation":"4-3-3"}'::jsonb,
   '[
     {"name":"Bounou","team":"Morocco","role":"P","stars":5,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Hincapié","team":"Ecuador","role":"D","stars":4,"flag":"🇪🇨","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Alexander-Arnold","team":"England","role":"D","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Danilo Pereira","team":"Portugal","role":"D","stars":3,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Granqvist","team":"Sweden","role":"D","stars":3,"flag":"🇸🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kouyaté","team":"Senegal","role":"C","stars":3,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"De Arrascaeta","team":"Uruguay","role":"C","stars":4,"flag":"🇺🇾","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Zieliński","team":"Poland","role":"C","stars":5,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Yamal","team":"Spain","role":"A","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Budimir","team":"Croatia","role":"A","stars":3,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ismaïla Sarr","team":"Senegal","role":"A","stars":4,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-3-3"', 'Yamal|Spain', 8, false,
   extract(epoch from now()-interval '3 hours')::bigint * 1000),

  ('WCFan99', :'round',
   '{"name":"Rui Vitória","team":"Egypt","flag":"🇪🇬","formation":"4-5-1"}'::jsonb,
   '[
     {"name":"Camilo Vargas","team":"Colombia","role":"P","stars":3,"flag":"🇨🇴","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Itakura","team":"Japan","role":"D","stars":3,"flag":"🇯🇵","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mojica","team":"Colombia","role":"D","stars":3,"flag":"🇨🇴","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Gomaa","team":"Egypt","role":"D","stars":3,"flag":"🇪🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Muñoz","team":"Colombia","role":"D","stars":3,"flag":"🇨🇴","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Sabiri","team":"Morocco","role":"C","stars":3,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Diatta","team":"Senegal","role":"C","stars":3,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Afsha","team":"Egypt","role":"C","stars":3,"flag":"🇪🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"E. Valencia","team":"Ecuador","role":"A","stars":3,"flag":"🇪🇨","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Immobile","team":"Italy","role":"A","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pavón","team":"Chile","role":"A","stars":3,"flag":"🇨🇱","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-3-3"', 'E. Valencia|Ecuador', 6, false,
   extract(epoch from now()-interval '2 hours 30 minutes')::bigint * 1000),

  ('SuperCoppa', :'round',
   '{"name":"Luciano Spalletti","team":"Italy","flag":"🇮🇹","formation":"3-5-2"}'::jsonb,
   '[
     {"name":"Donnarumma","team":"Italy","role":"P","stars":5,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ajayi","team":"Nigeria","role":"D","stars":3,"flag":"🇳🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pavlović","team":"Serbia","role":"D","stars":3,"flag":"🇷🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Vestergaard","team":"Denmark","role":"D","stars":4,"flag":"🇩🇰","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lukić","team":"Serbia","role":"C","stars":3,"flag":"🇷🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bentancur","team":"Uruguay","role":"C","stars":4,"flag":"🇺🇾","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Kroos","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"De Paul","team":"Argentina","role":"C","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Elanga","team":"Sweden","role":"C","stars":4,"flag":"🇸🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Vinicius Jr.","team":"Brazil","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ismaïla Sarr","team":"Senegal","role":"A","stars":4,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"3-5-2"', 'Kroos|Germany', 5, false,
   extract(epoch from now()-interval '2 hours')::bigint * 1000),

  ('Mister_X', :'round',
   '{"name":"Hong Myung-bo","team":"South Korea","flag":"🇰🇷","formation":"4-5-1"}'::jsonb,
   '[
     {"name":"Matt Turner","team":"USA","role":"P","stars":4,"flag":"🇺🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Jakobs","team":"Senegal","role":"D","stars":3,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Cash","team":"Poland","role":"D","stars":3,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Faes","team":"Belgium","role":"D","stars":3,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Danilo","team":"Brazil","role":"D","stars":4,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Amrabat","team":"Morocco","role":"C","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"de Roon","team":"Netherlands","role":"C","stars":3,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Szymański","team":"Poland","role":"C","stars":4,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lookman","team":"Nigeria","role":"A","stars":5,"flag":"🇳🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Lukaku","team":"Belgium","role":"A","stars":5,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Pulisic","team":"USA","role":"A","stars":5,"flag":"🇺🇸","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-3-3"', 'Lukaku|Belgium', 4, false,
   extract(epoch from now()-interval '1 hour 30 minutes')::bigint * 1000),

  ('UltrasTifoso', :'round',
   '{"name":"Zlatko Dalić","team":"Croatia","flag":"🇭🇷","formation":"4-3-3"}'::jsonb,
   '[
     {"name":"Borjan","team":"Canada","role":"P","stars":3,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Maripán","team":"Chile","role":"D","stars":3,"flag":"🇨🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bah","team":"Denmark","role":"D","stars":3,"flag":"🇩🇰","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Ola Aina","team":"Nigeria","role":"D","stars":3,"flag":"🇳🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Laporte","team":"Spain","role":"D","stars":4,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Grillitsch","team":"Austria","role":"C","stars":3,"flag":"🇦🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Zizo","team":"Egypt","role":"C","stars":3,"flag":"🇪🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Iheanacho","team":"Nigeria","role":"C","stars":3,"flag":"🇳🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Gyökeres","team":"Sweden","role":"A","stars":5,"flag":"🇸🇪","pts":0,"finalPts":0,"isCaptain":true},
     {"name":"Budimir","team":"Croatia","role":"A","stars":3,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Mané","team":"Senegal","role":"A","stars":5,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false}
   ]'::jsonb,
   '"4-3-3"', 'Gyökeres|Sweden', 2, false,
   extract(epoch from now()-interval '1 hour')::bigint * 1000),

  ('BallondOr26', :'round',
   '{"name":"Luis de la Fuente","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}'::jsonb,
   '[
     {"name":"Danny Ward","team":"Wales","role":"P","stars":3,"flag":"🏴󠁧󠁢󠁷󠁬󠁳󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Laimer","team":"Austria","role":"D","stars":4,"flag":"🇦🇹","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Hincapié","team":"Ecuador","role":"D","stars":4,"flag":"🇪🇨","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"C. Roberts","team":"Wales","role":"D","stars":3,"flag":"🏴󠁧󠁢󠁷󠁬󠁳󠁿","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Guilherme Arana","team":"Brazil","role":"D","stars":3,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Bae Jun-ho","team":"South Korea","role":"C","stars":4,"flag":"🇰🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Palacios","team":"Chile","role":"C","stars":3,"flag":"🇨🇱","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Trezeguet","team":"Egypt","role":"C","stars":3,"flag":"🇪🇬","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Hwang Hee-chan","team":"South Korea","role":"A","stars":4,"flag":"🇰🇷","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Pellistri","team":"Uruguay","role":"A","stars":3,"flag":"🇺🇾","pts":0,"finalPts":0,"isCaptain":false},
     {"name":"Musah","team":"USA","role":"C","stars":4,"flag":"🇺🇸","pts":0,"finalPts":0,"isCaptain":true}
   ]'::jsonb,
   '"4-4-2"', 'Musah|USA', 0, false,
   extract(epoch from now()-interval '30 minutes')::bigint * 1000)
;

-- Verifica risultato
select nickname, score, formation, captain
  from public.drafts
  where round = :'round'
  order by score desc;
