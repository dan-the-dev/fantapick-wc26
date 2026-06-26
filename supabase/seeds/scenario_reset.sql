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
