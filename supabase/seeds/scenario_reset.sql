-- ============================================================
-- scenario_reset.sql — Sedicesimi, nessuna partita giocata
-- Stato: r32 upcoming, nessun risultato, 3 draft di esempio
-- ============================================================

update public.round_state set state = 'upcoming', updated_at = now()
where round = 'r32';

-- Tre draft di esempio per avere una leaderboard non vuota
insert into public.drafts
  (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, ts)
values
  (
    'Tifoso_Milano', 'r32',
    '{"name":"Spalletti","team":"Italy","flag":"🇮🇹","formation":"4-3-3"}',
    '[
      {"name":"Donnarumma","team":"Italy","role":"P","stars":5,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Di Lorenzo","team":"Italy","role":"D","stars":3,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bastoni","team":"Italy","role":"D","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Messi","team":"Argentina","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Vinicius Jr.","team":"Brazil","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bellingham","team":"England","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Barella","team":"Italy","role":"C","stars":4,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Acerbi","team":"Italy","role":"D","stars":3,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Dimarco","team":"Italy","role":"D","stars":3,"flag":"🇮🇹","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"',
    'Mbappé|France',
    0, false,
    extract(epoch from now() - interval '10 minutes') * 1000
  ),
  (
    'DraftKing99', 'r32',
    '{"name":"Ancelotti","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}',
    '[
      {"name":"Courtois","team":"Belgium","role":"P","stars":5,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Hakimi","team":"Morocco","role":"D","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"De Ligt","team":"Netherlands","role":"D","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Cancelo","team":"Portugal","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"De Bruyne","team":"Belgium","role":"C","stars":5,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Kroos","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Pedri","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Ronaldo","team":"Portugal","role":"A","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Lewandowski","team":"Poland","role":"A","stars":5,"flag":"🇵🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kane","team":"England","role":"A","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"',
    'De Bruyne|Belgium',
    0, false,
    extract(epoch from now() - interval '8 minutes') * 1000
  ),
  (
    'FantaMaster', 'r32',
    '{"name":"Guardiola","team":"Spain","flag":"🇪🇸","formation":"4-3-3"}',
    '[
      {"name":"Neuer","team":"Germany","role":"P","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Koundé","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Varane","team":"France","role":"D","stars":4,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Rúben Dias","team":"Portugal","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Trippier","team":"England","role":"D","stars":3,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Musiala","team":"Germany","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bellingham","team":"England","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Gavi","team":"Spain","role":"C","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Mbappé","team":"France","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Vinicius Jr.","team":"Brazil","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Lautaro Martínez","team":"Argentina","role":"A","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"',
    'Mbappé|France',
    0, false,
    extract(epoch from now() - interval '5 minutes') * 1000
  )
on conflict (round, nickname) do update
  set picks = excluded.picks, coach = excluded.coach,
      formation = excluded.formation, captain = excluded.captain,
      score = 0, ct_bonus_applied = false, ts = excluded.ts, updated_at = now();

-- Dieci draft aggiuntivi con giocatori reali da squads-complete.json
insert into public.drafts
  (nickname, round, coach, picks, formation, captain, score, ct_bonus_applied, swap_count, retry_used, ts)
values
  (
    'TifosoMilan82', 'r32',
    '{"name":"Nagelsmann","team":"GER","flag":"🇩🇪","formation":"4-3-3"}',
    '[
      {"name":"Manuel Neuer","team":"GER","role":"P","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Antonio Rüdiger","team":"GER","role":"D","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Joško Gvardiol","team":"CRO","role":"D","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Achraf Hakimi","team":"MAR","role":"D","stars":5,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jamal Musiala","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Fernandes","team":"POR","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kevin De Bruyne","team":"BEL","role":"C","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kylian Mbappé","team":"FRA","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Viktor Gyökeres","team":"SWE","role":"A","stars":5,"flag":"🇸🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Christian Pulisic","team":"USA","role":"A","stars":4,"flag":"🇺🇸","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Kylian Mbappé|FRA',
    0, false, 1, false,
    extract(epoch from now() - interval '6 hours') * 1000
  ),
  (
    'FantaKing99', 'r32',
    '{"name":"Deschamps","team":"FRA","flag":"🇫🇷","formation":"4-3-3"}',
    '[
      {"name":"Thibaut Courtois","team":"BEL","role":"P","stars":5,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Denzel Dumfries","team":"NED","role":"D","stars":5,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Rúben Dias","team":"POR","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Joško Gvardiol","team":"CRO","role":"D","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Florian Wirtz","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Tijjani Reijnders","team":"NED","role":"C","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Fernandes","team":"POR","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kylian Mbappé","team":"FRA","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Lionel Messi","team":"ARG","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Vinícius Júnior","team":"BRA","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Lionel Messi|ARG',
    0, false, 0, false,
    extract(epoch from now() - interval '5 hours 30 minutes') * 1000
  ),
  (
    'Scudetto2026', 'r32',
    '{"name":"Garcia","team":"BEL","flag":"🇧🇪","formation":"4-3-3"}',
    '[
      {"name":"Diogo Costa","team":"POR","role":"P","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Rúben Dias","team":"POR","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Arthur Theate","team":"BEL","role":"D","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Achraf Hakimi","team":"MAR","role":"D","stars":5,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kevin De Bruyne","team":"BEL","role":"C","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Florian Wirtz","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bernardo Silva","team":"POR","role":"C","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Cristiano Ronaldo","team":"POR","role":"A","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Lamine Yamal","team":"ESP","role":"A","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Romelu Lukaku","team":"BEL","role":"A","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Cristiano Ronaldo|POR',
    0, false, 2, true,
    extract(epoch from now() - interval '5 hours') * 1000
  ),
  (
    'DraftMaster', 'r32',
    '{"name":"Martínez","team":"POR","flag":"🇵🇹","formation":"4-3-3"}',
    '[
      {"name":"Alisson","team":"BRA","role":"P","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Alphonso Davies","team":"CAN","role":"D","stars":4,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Marquinhos","team":"BRA","role":"D","stars":4,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Cristian Romero","team":"ARG","role":"D","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Joško Gvardiol","team":"CRO","role":"D","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jude Bellingham","team":"ENG","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Enzo Fernández","team":"ARG","role":"C","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jamal Musiala","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Julián Álvarez","team":"ARG","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Harry Kane","team":"ENG","role":"A","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Raphinha","team":"BRA","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Jude Bellingham|ENG',
    0, false, 1, false,
    extract(epoch from now() - interval '4 hours 30 minutes') * 1000
  ),
  (
    'CurvaNord', 'r32',
    '{"name":"Koeman","team":"NED","flag":"🇳🇱","formation":"4-3-3"}',
    '[
      {"name":"Thibaut Courtois","team":"BEL","role":"P","stars":5,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Denzel Dumfries","team":"NED","role":"D","stars":5,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Virgil van Dijk","team":"NED","role":"D","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Joško Gvardiol","team":"CRO","role":"D","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Tijjani Reijnders","team":"NED","role":"C","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Fernandes","team":"POR","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jamal Musiala","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Viktor Gyökeres","team":"SWE","role":"A","stars":5,"flag":"🇸🇪","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Sadio Mané","team":"SEN","role":"A","stars":4,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jonathan David","team":"CAN","role":"A","stars":4,"flag":"🇨🇦","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Viktor Gyökeres|SWE',
    0, false, 0, true,
    extract(epoch from now() - interval '4 hours') * 1000
  ),
  (
    'CalcioNerd', 'r32',
    '{"name":"Scaloni","team":"ARG","flag":"🇦🇷","formation":"4-3-3"}',
    '[
      {"name":"Emiliano Martínez","team":"ARG","role":"P","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nicolás Otamendi","team":"ARG","role":"D","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Cristian Romero","team":"ARG","role":"D","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nicolás Tagliafico","team":"ARG","role":"D","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Achraf Hakimi","team":"MAR","role":"D","stars":5,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Enzo Fernández","team":"ARG","role":"C","stars":4,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jude Bellingham","team":"ENG","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Florian Wirtz","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Lionel Messi","team":"ARG","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Lautaro Martínez","team":"ARG","role":"A","stars":5,"flag":"🇦🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kylian Mbappé","team":"FRA","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Lionel Messi|ARG',
    0, false, 2, false,
    extract(epoch from now() - interval '3 hours 30 minutes') * 1000
  ),
  (
    'ForziAzzurri', 'r32',
    '{"name":"Tuchel","team":"ENG","flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","formation":"4-3-3"}',
    '[
      {"name":"Jordan Pickford","team":"ENG","role":"P","stars":4,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Marc Guéhi","team":"ENG","role":"D","stars":4,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nico O''Reilly","team":"ENG","role":"D","stars":4,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Antonio Rüdiger","team":"GER","role":"D","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jude Bellingham","team":"ENG","role":"C","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Declan Rice","team":"ENG","role":"C","stars":3,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kevin De Bruyne","team":"BEL","role":"C","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Harry Kane","team":"ENG","role":"A","stars":5,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Bukayo Saka","team":"ENG","role":"A","stars":4,"flag":"🏴󠁧󠁢󠁥󠁮󠁧󠁿","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kylian Mbappé","team":"FRA","role":"A","stars":5,"flag":"🇫🇷","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Harry Kane|ENG',
    0, false, 1, false,
    extract(epoch from now() - interval '3 hours') * 1000
  ),
  (
    'MaestroDelDraft', 'r32',
    '{"name":"Nagelsmann","team":"GER","flag":"🇩🇪","formation":"4-3-3"}',
    '[
      {"name":"Manuel Neuer","team":"GER","role":"P","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Antonio Rüdiger","team":"GER","role":"D","stars":4,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Virgil van Dijk","team":"NED","role":"D","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Joško Gvardiol","team":"CRO","role":"D","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Jamal Musiala","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Florian Wirtz","team":"GER","role":"C","stars":5,"flag":"🇩🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Fernandes","team":"POR","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Vinícius Júnior","team":"BRA","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Lamine Yamal","team":"ESP","role":"A","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Viktor Gyökeres","team":"SWE","role":"A","stars":5,"flag":"🇸🇪","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Vinícius Júnior|BRA',
    0, false, 0, true,
    extract(epoch from now() - interval '2 hours 30 minutes') * 1000
  ),
  (
    'SerieALover', 'r32',
    '{"name":"Ancelotti","team":"BRA","flag":"🇧🇷","formation":"4-3-3"}',
    '[
      {"name":"Alisson","team":"BRA","role":"P","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Gabriel Magalhães","team":"BRA","role":"D","stars":4,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Marquinhos","team":"BRA","role":"D","stars":4,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Denzel Dumfries","team":"NED","role":"D","stars":5,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Guimarães","team":"BRA","role":"C","stars":3,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Fernandes","team":"POR","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Tijjani Reijnders","team":"NED","role":"C","stars":4,"flag":"🇳🇱","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Raphinha","team":"BRA","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Vinícius Júnior","team":"BRA","role":"A","stars":5,"flag":"🇧🇷","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Sadio Mané","team":"SEN","role":"A","stars":4,"flag":"🇸🇳","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Vinícius Júnior|BRA',
    0, false, 1, false,
    extract(epoch from now() - interval '2 hours') * 1000
  ),
  (
    'FantaWizard', 'r32',
    '{"name":"Martínez","team":"POR","flag":"🇵🇹","formation":"4-3-3"}',
    '[
      {"name":"Diogo Costa","team":"POR","role":"P","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Nuno Mendes","team":"POR","role":"D","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Diogo Dalot","team":"POR","role":"D","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Joško Gvardiol","team":"CRO","role":"D","stars":4,"flag":"🇭🇷","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Achraf Hakimi","team":"MAR","role":"D","stars":5,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bruno Fernandes","team":"POR","role":"C","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Bernardo Silva","team":"POR","role":"C","stars":4,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Kevin De Bruyne","team":"BEL","role":"C","stars":4,"flag":"🇧🇪","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Cristiano Ronaldo","team":"POR","role":"A","stars":5,"flag":"🇵🇹","pts":0,"finalPts":0,"isCaptain":true},
      {"name":"Brahim Díaz","team":"MAR","role":"A","stars":4,"flag":"🇲🇦","pts":0,"finalPts":0,"isCaptain":false},
      {"name":"Lamine Yamal","team":"ESP","role":"A","stars":5,"flag":"🇪🇸","pts":0,"finalPts":0,"isCaptain":false}
    ]',
    '"4-3-3"', 'Cristiano Ronaldo|POR',
    0, false, 2, true,
    extract(epoch from now() - interval '1 hour') * 1000
  )
on conflict (round, nickname) do update
  set picks = excluded.picks, coach = excluded.coach,
      formation = excluded.formation, captain = excluded.captain,
      score = 0, ct_bonus_applied = false,
      swap_count = excluded.swap_count, retry_used = excluded.retry_used,
      ts = excluded.ts, updated_at = now();
