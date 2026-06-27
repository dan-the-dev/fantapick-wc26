'use strict';

/* ============================================================
   ENVIRONMENT
   ============================================================ */
const IS_LOCAL = ['localhost','127.0.0.1'].includes(location.hostname)
              || location.search.includes('env=local');

/* ============================================================
   SUPABASE
   ============================================================ */
const SUPABASE_URL = IS_LOCAL
  ? 'http://127.0.0.1:54321'
  : 'https://pngglilremuetaphpuem.supabase.co';

const SUPABASE_ANON_KEY = IS_LOCAL
  ? 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
  : 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBuZ2dsaWxyZW11ZXRhcGhwdWVtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0OTYxNzYsImV4cCI6MjA5ODA3MjE3Nn0.gzk0PkPKAHSz1iMiIGVIopJWGytTohtwOsrE-tSlhJA';

const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

/* ============================================================
   DEV MODE  — set true locally, or append ?dev to URL
   ============================================================ */
const DEV_MODE = new URLSearchParams(location.search).has('dev') || false;

/* ============================================================
   CONFIG
   ============================================================ */
const CURRENT_ROUND = 'r32';
const STORAGE_KEY   = 'fantapick_wc26_state';
const DRAFT_KEY     = 'fantapick_wc26_draft_state';

const ROUND_NAMES = {
  r32:   'Sedicesimi',
  r16:   'Ottavi',
  qf:    'Quarti',
  sf:    'Semifinali',
  final: 'Finale',
};

const SCORING = {
  goal:          3,
  assist:        1,
  pen_goal:      3,
  pen_save:      3,
  clean_sheet:   1,
  yellow:       -0.5,
  red:          -1,
  goal_conceded:-1,
  pen_miss:     -3,
  own_goal:     -2,
  win:           1,
  loss:         -1,
  draw:          0,
};

const CT_MULTIPLIER  = 1.25;
const CAPTAIN_FACTOR = 1.5;
const PICK_TOTAL     = 11;

const ADMIN_PASSWORD    = 'fantapick2026';
const ADMIN_SESSION_KEY = 'fantapick_wc26_admin_auth';

/* ============================================================
   IN-MEMORY CACHE  (populated from Supabase on init, kept in sync)
   Reads are synchronous (cache); writes are async (Supabase).
   ============================================================ */
let _roundState      = { currentRound: CURRENT_ROUND, roundState: 'upcoming' };
let _matchData       = {};   // { [round]: { [matchId]: { homeScore, awayScore, completed, players } } }
let _allDrafts       = {};   // { [round]: [ draftEntry, … ] } sorted by score desc
let _qualifiedTeams  = [];   // array of team_code strings for CURRENT_ROUND
let _pickerCtx       = null; // { matchId, eventType } for player-picker drawer

/* ============================================================
   11 FORMATIONS  { d, c, a, slots[11:{r,pos}] }
   ============================================================ */
const FORMATIONS = {
  '4-4-2': {
    d:4, c:4, a:2,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[16,72]},{r:'D', pos:[37,72]},{r:'D', pos:[63,72]},{r:'D', pos:[84,72]},
      {r:'C', pos:[16,52]},{r:'C', pos:[37,52]},{r:'C', pos:[63,52]},{r:'C', pos:[84,52]},
      {r:'A', pos:[34,22]},{r:'A', pos:[66,22]},
    ]
  },
  '4-3-3': {
    d:4, c:3, a:3,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[16,72]},{r:'D', pos:[37,72]},{r:'D', pos:[63,72]},{r:'D', pos:[84,72]},
      {r:'C', pos:[22,52]},{r:'C', pos:[50,52]},{r:'C', pos:[78,52]},
      {r:'A', pos:[18,26]},{r:'A', pos:[50,18]},{r:'A', pos:[82,26]},
    ]
  },
  '4-2-3-1': {
    d:4, c:5, a:1,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[16,72]},{r:'D', pos:[37,72]},{r:'D', pos:[63,72]},{r:'D', pos:[84,72]},
      {r:'C', pos:[34,60]},{r:'C', pos:[66,60]},
      {r:'C', pos:[16,42]},{r:'C', pos:[50,40]},{r:'C', pos:[84,42]},
      {r:'A', pos:[50,18]},
    ]
  },
  '4-3-1-2': {
    d:4, c:4, a:2,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[16,72]},{r:'D', pos:[37,72]},{r:'D', pos:[63,72]},{r:'D', pos:[84,72]},
      {r:'C', pos:[22,56]},{r:'C', pos:[50,56]},{r:'C', pos:[78,56]},
      {r:'C', pos:[50,38]},
      {r:'A', pos:[34,20]},{r:'A', pos:[66,20]},
    ]
  },
  '4-1-4-1': {
    d:4, c:5, a:1,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[16,72]},{r:'D', pos:[37,72]},{r:'D', pos:[63,72]},{r:'D', pos:[84,72]},
      {r:'C', pos:[50,62]},
      {r:'C', pos:[14,46]},{r:'C', pos:[36,46]},{r:'C', pos:[64,46]},{r:'C', pos:[86,46]},
      {r:'A', pos:[50,18]},
    ]
  },
  '3-5-2': {
    d:3, c:5, a:2,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[24,72]},{r:'D', pos:[50,74]},{r:'D', pos:[76,72]},
      {r:'C', pos:[10,52]},{r:'C', pos:[30,50]},{r:'C', pos:[50,50]},{r:'C', pos:[70,50]},{r:'C', pos:[90,52]},
      {r:'A', pos:[34,22]},{r:'A', pos:[66,22]},
    ]
  },
  '3-4-3': {
    d:3, c:4, a:3,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[24,72]},{r:'D', pos:[50,74]},{r:'D', pos:[76,72]},
      {r:'C', pos:[18,52]},{r:'C', pos:[40,52]},{r:'C', pos:[60,52]},{r:'C', pos:[82,52]},
      {r:'A', pos:[18,26]},{r:'A', pos:[50,18]},{r:'A', pos:[82,26]},
    ]
  },
  '3-4-1-2': {
    d:3, c:5, a:2,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[24,72]},{r:'D', pos:[50,74]},{r:'D', pos:[76,72]},
      {r:'C', pos:[16,54]},{r:'C', pos:[38,54]},{r:'C', pos:[62,54]},{r:'C', pos:[84,54]},
      {r:'C', pos:[50,36]},
      {r:'A', pos:[34,20]},{r:'A', pos:[66,20]},
    ]
  },
  '3-5-1-1': {
    d:3, c:6, a:1,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[24,72]},{r:'D', pos:[50,74]},{r:'D', pos:[76,72]},
      {r:'C', pos:[8,52]},{r:'C', pos:[26,50]},{r:'C', pos:[50,50]},{r:'C', pos:[74,50]},{r:'C', pos:[92,52]},
      {r:'C', pos:[50,34]},
      {r:'A', pos:[50,18]},
    ]
  },
  '5-3-2': {
    d:5, c:3, a:2,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[8,72]},{r:'D', pos:[26,70]},{r:'D', pos:[50,74]},{r:'D', pos:[74,70]},{r:'D', pos:[92,72]},
      {r:'C', pos:[24,50]},{r:'C', pos:[50,50]},{r:'C', pos:[76,50]},
      {r:'A', pos:[34,22]},{r:'A', pos:[66,22]},
    ]
  },
  '5-4-1': {
    d:5, c:4, a:1,
    slots:[
      {r:'P', pos:[50,87]},
      {r:'D', pos:[8,72]},{r:'D', pos:[26,70]},{r:'D', pos:[50,74]},{r:'D', pos:[74,70]},{r:'D', pos:[92,72]},
      {r:'C', pos:[18,50]},{r:'C', pos:[38,50]},{r:'C', pos:[62,50]},{r:'C', pos:[82,50]},
      {r:'A', pos:[50,18]},
    ]
  },
};
const FORMATION_LIST = Object.keys(FORMATIONS);

function parseDCA(f) {
  const parts = (f||'').split('-').map(Number);
  if (parts.length < 2 || parts.some(isNaN)) return null;
  return { d: parts[0], a: parts[parts.length-1], c: parts.slice(1,-1).reduce((s,n)=>s+n,0) };
}

/* ============================================================
   GAME STATE
   ============================================================ */
const S = {
  round:            CURRENT_ROUND,
  pickIndex:        0,
  ctOptions:        [],
  selectedCT:       null,
  playerPool:       [],
  usedKeys:         new Set(),
  drafted:          [],
  candidatesCache:  null,
  /* formation screen */
  formation:        '4-3-3',
  slotAssign:       Array(11).fill(null),
  selectedBench:    null,
  captainKey:       null,
  swapsLeft:        3,
  swapTargetSlotIdx: null,
  retryUsed:        false,
  resultData:       null,
  restored:         false,
  /* pool persistence */
  draftSeed:        null,
  pools:            null,
  swapPools:        [],
  activeSwapPool:   null,
};

let SWAP_CANDIDATES = [];

/* ============================================================
   DATA
   ============================================================ */
let DATA = { squads: null, fixtures: null, results: null };

async function loadData() {
  const [squads, fixtures, results] = await Promise.all([
    fetch('data/squads-complete.json').then(r => r.json()),
    fetch('data/fixtures-r32.json').then(r => r.json()),
    fetch('data/round-results.json').then(r => r.json()),
  ]);
  DATA.squads = squads; DATA.fixtures = fixtures; DATA.results = results;
}

/* ============================================================
   LOCAL STORAGE
   ============================================================ */
function loadStorage() {
  try { return JSON.parse(localStorage.getItem(STORAGE_KEY)) || {}; } catch { return {}; }
}
function saveStorage(obj) {
  try { localStorage.setItem(STORAGE_KEY, JSON.stringify(obj)); } catch {}
}
function getNickname()      { return loadStorage().nickname || null; }
function setNickname(n) {
  const s = loadStorage(); s.nickname = n.trim().slice(0,20) || 'Anonimo'; saveStorage(s); return s.nickname;
}
function validateNickname(val) {
  if (val.length < 2)  return { ok: false, message: 'Minimo 2 caratteri' };
  if (val.length > 20) return { ok: false, message: 'Massimo 20 caratteri' };
  if (!/^[a-zA-Z0-9_\-.]+$/.test(val)) return { ok: false, message: 'Solo lettere, numeri, _ - .' };
  return { ok: true, message: '✓' };
}
function getCompletedDraft(round) { return (loadStorage().drafts || {})[round] || null; }
function saveCompletedDraft(round, data) {
  const s = loadStorage(); s.drafts = s.drafts || {}; s.drafts[round] = data; saveStorage(s);
}
/* -------- Draft state persistence -------- */
function saveDraftState(phase) {
  if (DEV_MODE || !DATA.squads) return;
  try {
    localStorage.setItem(DRAFT_KEY, JSON.stringify({
      round: CURRENT_ROUND, phase,
      seed:            S.draftSeed,
      pools:           S.pools,
      swapPools:       S.swapPools,
      activeSwapPool:  S.activeSwapPool,
      pickIndex:       S.pickIndex,
      coach:           S.selectedCT,
      picks:           S.drafted,
      swapsLeft:       S.swapsLeft,
      retryUsed:       S.retryUsed,
      formation:       S.formation,
      slotAssign:      S.slotAssign,
      captainKey:      S.captainKey,
      swapTargetSlotIdx: S.swapTargetSlotIdx,
      timestamp:       Date.now(),
    }));
  } catch {}
}
function clearDraftState() { try { localStorage.removeItem(DRAFT_KEY); } catch {} }
function loadSavedDraft()   { try { return JSON.parse(localStorage.getItem(DRAFT_KEY)); } catch { return null; } }
function restoreDraftState(saved) {
  S.draftSeed        = saved.seed || null;
  S.pools            = saved.pools || null;
  S.swapPools        = saved.swapPools || [];
  S.activeSwapPool   = saved.activeSwapPool || null;
  S.selectedCT       = saved.coach || null;
  S.ctOptions        = S.pools?.[0]?.candidates || (saved.coach ? [saved.coach] : []);
  S.drafted          = saved.picks || [];
  S.pickIndex        = saved.pickIndex || 0;
  S.swapsLeft        = saved.swapsLeft ?? 3;
  S.retryUsed        = saved.retryUsed || false;
  S.formation        = saved.formation || '4-3-3';
  S.slotAssign       = (saved.slotAssign || Array(11).fill(null)).map(sp => sp || null);
  S.captainKey       = saved.captainKey || null;
  S.selectedBench    = null;
  S.swapTargetSlotIdx= saved.swapTargetSlotIdx ?? null;
  S.candidatesCache  = null;
  S.resultData       = null;
  S.restored         = true;
  S.playerPool       = buildPlayerPool();
  S.usedKeys         = new Set(S.drafted.map(playerKey));
}

/* -------- Round State (cache-backed) -------- */
function getRoundState() { return _roundState; }
async function setRoundState(s) {
  _roundState = s;
  const { error } = await sb.from('round_state')
    .upsert({ round: s.currentRound, state: s.roundState }, { onConflict: 'round' });
  if (error) console.error('setRoundState:', error);
}

/* -------- Match Data (cache-backed) -------- */
function getMatchData() { return _matchData; }

/* -------- All Drafts (cache-backed) -------- */
function getAllDrafts() { return _allDrafts; }

/* row → entry */
function draftFromRow(d) {
  return {
    nick:           d.nickname,
    score:          d.score     || 0,
    formation:      d.formation,
    captainKey:     d.captain,
    ct:             d.coach,
    ctBonusApplied: d.ct_bonus_applied || false,
    breakdown:      d.picks     || [],
    ts:             d.ts        || 0,
  };
}
/* entry → row */
function draftToRow(round, entry) {
  return {
    round,
    nickname:         entry.nick,
    coach:            entry.ct,
    picks:            entry.breakdown || [],
    formation:        entry.formation,
    captain:          entry.captainKey,
    score:            entry.score || 0,
    ct_bonus_applied: entry.ctBonusApplied || false,
    swap_count:       entry.swapsUsed || 0,
    retry_used:       entry.retryUsed || false,
    ts:               entry.ts || Date.now(),
  };
}

/* -------- Admin Auth -------- */
function isAdminAuthed() { return sessionStorage.getItem(ADMIN_SESSION_KEY) === '1'; }
function setAdminAuth()   { sessionStorage.setItem(ADMIN_SESSION_KEY, '1'); }

/* ============================================================
   HELPERS
   ============================================================ */
function esc(s) {
  return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}
function starsHtml(n) {
  return '<span class="stars">' + Array.from({length:5},(_,i)=>`<span class="${i<n?'':'empty'}">★</span>`).join('') + '</span>';
}
function roleClass(r) { return {P:'role-p',D:'role-d',C:'role-c',A:'role-a'}[r]||''; }
function roleName(r)  { return {P:'POR',D:'DIF',C:'CEN',A:'ATT'}[r]||r; }
function playerKey(p) { return `${p.name}|${p.team}`; }

const TEAM_ABBR = {'Netherlands':'NED','South Korea':'KOR','Switzerland':'SUI','Costa Rica':'CRC'};
function teamAbbr(t) { return TEAM_ABBR[t] || t.slice(0,3).toUpperCase(); }
function getPlayerFixture(p) {
  const m = (DATA.fixtures?.matches||[]).find(m => m.home===p.team||m.away===p.team);
  return m ? `${teamAbbr(m.home)} vs ${teamAbbr(m.away)}` : null;
}

function getRoundTeams() {
  return new Set(DATA.fixtures.matches.flatMap(m => [m.home, m.away]));
}
function buildPlayerPool() {
  const roundTeams = _qualifiedTeams.length > 0
    ? new Set(_qualifiedTeams)
    : getRoundTeams();
  const pool = [];
  for (const sq of DATA.squads) {
    if (!roundTeams.has(sq.team)) continue;
    for (const p of sq.players) pool.push({ ...p, team: sq.team, flag: sq.flag });
  }
  return pool;
}
function shuffle(arr) {
  const a = arr.slice();
  for (let i=a.length-1;i>0;i--){ const j=Math.floor(Math.random()*(i+1));[a[i],a[j]]=[a[j],a[i]]; }
  return a;
}
function sampleN(arr, n) { return shuffle(arr).slice(0, n); }

/* Seeded PRNG — FNV-1a hash of seed string → xorshift32 */
function mkRng(seed) {
  let h = 2166136261 >>> 0;
  for (let i = 0; i < seed.length; i++) { h ^= seed.charCodeAt(i); h = Math.imul(h, 16777619) >>> 0; }
  let s = h || 1;
  return () => { s ^= s << 13; s ^= s >>> 17; s ^= s << 5; return (s >>> 0) / 4294967296; };
}
function shuffleRng(arr, rng) {
  const a = arr.slice();
  for (let i = a.length - 1; i > 0; i--) { const j = Math.floor(rng() * (i + 1)); [a[i], a[j]] = [a[j], a[i]]; }
  return a;
}

function roleCounts() {
  const c = {P:0,D:0,C:0,A:0};
  for (const p of S.drafted) c[p.role]++;
  return c;
}
function forcedRoles() {
  const rc = roleCounts();
  const remaining = PICK_TOTAL - S.drafted.length;
  const needP = Math.max(0,1-rc.P), needD = Math.max(0,3-rc.D),
        needC = Math.max(0,2-rc.C), needA = Math.max(0,1-rc.A);
  const mandatory = needP+needD+needC+needA;
  if (mandatory < remaining) return [];
  const f = [];
  for (let i=0;i<needP;i++) f.push('P');
  for (let i=0;i<needD;i++) f.push('D');
  for (let i=0;i<needC;i++) f.push('C');
  for (let i=0;i<needA;i++) f.push('A');
  return f;
}
function getCandidates() {
  if (S.candidatesCache) return S.candidatesCache;
  // Use pre-generated pool if available
  const prebuilt = S.pools?.[S.pickIndex];
  if (prebuilt) {
    S.candidatesCache = prebuilt.candidates;
    return S.candidatesCache;
  }
  // Fallback: generate dynamically (legacy / edge case)
  const available = S.playerPool.filter(p => !S.usedKeys.has(playerKey(p)));
  const forced = forcedRoles();
  let pool = available;
  if (forced.length > 0) {
    const filtered = available.filter(p => p.role === forced[0]);
    if (filtered.length > 0) pool = filtered;
  }
  const byRole = {P:[],D:[],C:[],A:[]};
  for (const p of pool) (byRole[p.role]||[]).push(p);
  const candidates = [], seen = new Set();
  for (const r of shuffle(['P','D','D','C','C','A','A','D','C','A'])) {
    if (candidates.length >= 4) break;
    const pick = sampleN(byRole[r]||[],3).find(p => !seen.has(playerKey(p)));
    if (pick) { candidates.push(pick); seen.add(playerKey(pick)); }
  }
  for (const p of shuffle(pool)) {
    if (candidates.length >= 4) break;
    if (!seen.has(playerKey(p))) { candidates.push(p); seen.add(playerKey(p)); }
  }
  S.candidatesCache = candidates.slice(0,4);
  return S.candidatesCache;
}
function getCtOptions() {
  const roundTeams = getRoundTeams();
  return sampleN(DATA.squads
    .filter(sq => roundTeams.has(sq.team))
    .map(sq => ({name:sq.coach, team:sq.team, flag:sq.flag, formation:sq.formation})), 3);
}

/* Pre-compute all 12 pick pools (0=CT, 1-11=players) using seeded RNG.
   Pools are non-overlapping: each pool's 4 candidates are excluded from future pools.
   Forced-role logic is simulated by assuming the user picks pool[n].candidates[0]. */
function generateAllPools(rng) {
  if (!DATA.squads) return [];
  const roundTeams = getRoundTeams();

  // Pool 0: CT options
  const allCTs = shuffleRng(
    DATA.squads
      .filter(sq => roundTeams.has(sq.team))
      .map(sq => ({name: sq.coach, team: sq.team, flag: sq.flag, formation: sq.formation})),
    rng
  );
  const pools = [{ pick: 0, candidates: allCTs.slice(0, 3) }];

  // Pools 1-11: player picks
  const allPlayers = buildPlayerPool();
  const usedInPools = new Set();
  const simulatedDrafted = [];

  for (let pick = 1; pick <= PICK_TOTAL; pick++) {
    const available = allPlayers.filter(p => !usedInPools.has(playerKey(p)));

    // Simulate forced-role logic based on simulated draft history
    const simRc = {P:0,D:0,C:0,A:0};
    for (const p of simulatedDrafted) simRc[p.role]++;
    const rem = PICK_TOTAL - simulatedDrafted.length;
    const needP = Math.max(0,1-simRc.P), needD = Math.max(0,3-simRc.D),
          needC = Math.max(0,2-simRc.C), needA = Math.max(0,1-simRc.A);
    const mandatory = needP+needD+needC+needA;
    let forcedRole = null;
    if (mandatory >= rem) {
      if (needP>0) forcedRole='P';
      else if (needD>0) forcedRole='D';
      else if (needC>0) forcedRole='C';
      else if (needA>0) forcedRole='A';
    }

    let pool = available;
    if (forcedRole) {
      const filtered = available.filter(p => p.role === forcedRole);
      if (filtered.length > 0) pool = filtered;
    }

    const byRole = {P:[],D:[],C:[],A:[]};
    for (const p of pool) (byRole[p.role]||[]).push(p);

    const roleOrder = shuffleRng(['P','D','D','C','C','A','A','D','C','A'], rng);
    const candidates = [], seen = new Set();
    for (const r of roleOrder) {
      if (candidates.length >= 4) break;
      if (!byRole[r]?.length) continue;
      const p = shuffleRng(byRole[r], rng).find(p => !seen.has(playerKey(p)));
      if (p) { candidates.push(p); seen.add(playerKey(p)); }
    }
    for (const p of shuffleRng(pool, rng)) {
      if (candidates.length >= 4) break;
      if (!seen.has(playerKey(p))) { candidates.push(p); seen.add(playerKey(p)); }
    }

    const final = candidates.slice(0, 4);
    pools.push({ pick, candidates: final });
    final.forEach(p => usedInPools.add(playerKey(p)));
    if (final.length > 0) simulatedDrafted.push(final[0]);
  }

  return pools;
}

/* ============================================================
   SCORING ENGINE
   ============================================================ */
function getMatchForTeam(team) {
  return DATA.results.matches.find(m => m.home===team||m.away===team)||null;
}
function getTeamResult(team, match) {
  if (!match) return null;
  const isHome = match.home===team;
  const mine = isHome?match.home_goals:match.away_goals;
  const opp  = isHome?match.away_goals:match.home_goals;
  return mine>opp?'W':mine<opp?'L':'D';
}
function getGoalsConceded(team, match) {
  if (!match) return 0;
  return match.home===team?match.away_goals:match.home_goals;
}
function countEvents(name, team, arr) {
  return (arr||[]).filter(e=>e.player===name&&e.team===team).length;
}
function scorePlayer(p, match) {
  if (!match) return 0;
  const {name:n, team:t, role:r} = p;
  let pts = 0;
  pts += countEvents(n,t,match.goals)     * SCORING.goal;
  pts += countEvents(n,t,match.assists)   * SCORING.assist;
  pts += countEvents(n,t,match.pen_goals) * SCORING.pen_goal;
  pts += countEvents(n,t,match.yellows)   * SCORING.yellow;
  pts += countEvents(n,t,match.reds)      * SCORING.red;
  pts += countEvents(n,t,match.pen_misses)* SCORING.pen_miss;
  pts += countEvents(n,t,match.own_goals) * SCORING.own_goal;
  if (r==='P') {
    pts += countEvents(n,t,match.pen_saves) * SCORING.pen_save;
    pts += getGoalsConceded(t,match) * SCORING.goal_conceded;
    if (getGoalsConceded(t,match)===0) pts += SCORING.clean_sheet;
  }
  const res = getTeamResult(t,match);
  if (res==='W') pts += SCORING.win;
  if (res==='L') pts += SCORING.loss;
  return pts;
}

function computeResult() {
  const slotted = S.slotAssign.filter(Boolean);
  const ct      = S.selectedCT;
  const capKey  = S.captainKey;
  const matchCT = getMatchForTeam(ct.team);
  const ctFormUsed = matchCT
    ? (matchCT.home===ct.team ? matchCT.formation_home : matchCT.formation_away)
    : ct.formation;
  const userFDef = FORMATIONS[S.formation];
  const ctDCA    = parseDCA(ctFormUsed);
  const ctMulti  = (ctDCA && userFDef.d===ctDCA.d && userFDef.c===ctDCA.c && userFDef.a===ctDCA.a)
    ? CT_MULTIPLIER : 1.0;
  let rawTotal = 0;
  const breakdown = slotted.map(p => {
    const match    = getMatchForTeam(p.team);
    const pts      = scorePlayer(p, match);
    const isCap    = playerKey(p) === capKey;
    const finalPts = parseFloat((isCap ? pts*CAPTAIN_FACTOR : pts).toFixed(1));
    rawTotal += finalPts;
    return { ...p, pts, finalPts, isCaptain: isCap };
  });
  return {
    breakdown,
    total:           parseFloat((rawTotal*ctMulti).toFixed(1)),
    ctMulti,
    userFormation:   S.formation,
    ctFormationUsed: ctFormUsed,
    ctBonusApplied:  ctMulti > 1,
    ct,
  };
}

function calcPerfectXI() {
  const roundTeams = getRoundTeams();
  const allPlayers = [];
  for (const sq of DATA.squads) {
    if (!roundTeams.has(sq.team)) continue;
    for (const p of sq.players) {
      const pts = scorePlayer({...p, team:sq.team}, getMatchForTeam(sq.team));
      allPlayers.push({...p, team:sq.team, flag:sq.flag, pts});
    }
  }
  const byRole = {P:[],D:[],C:[],A:[]};
  for (const p of allPlayers) (byRole[p.role]||[]).push(p);
  for (const r in byRole) byRole[r].sort((a,b)=>b.pts-a.pts);
  let bestScore=-Infinity, bestPlayers=[];
  for (let d=3;d<=5;d++) for (let c=2;c<=7;c++) {
    const a=10-d-c;
    if (a<1||a>5) continue;
    if (byRole.P.length<1||byRole.D.length<d||byRole.C.length<c||byRole.A.length<a) continue;
    const combo=[...byRole.P.slice(0,1),...byRole.D.slice(0,d),...byRole.C.slice(0,c),...byRole.A.slice(0,a)];
    const score=combo.reduce((s,p)=>s+p.pts,0);
    if (score>bestScore){bestScore=score;bestPlayers=combo;}
  }
  return { players:bestPlayers, total:parseFloat(bestScore.toFixed(1)) };
}

/* ============================================================
   ADMIN SCORING ENGINE
   ============================================================ */
function jsProp(s) { return String(s).replace(/\\/g,'\\\\').replace(/'/g,"\\'"); }

function getAdminMatchForTeam(team, roundMd) {
  const fixture = (DATA.fixtures?.matches || []).find(m => m.home === team || m.away === team);
  if (!fixture) return null;
  const md = roundMd[fixture.id];
  if (!md) return null;
  return { id: fixture.id, home: fixture.home, away: fixture.away,
    homeScore: md.homeScore ?? 0, awayScore: md.awayScore ?? 0,
    completed: md.completed || false, players: md.players || {} };
}

/* player_stats format (JSONB):
   { events: [{id, type, playerKey, playerName, team, minute}], played: [playerKey,...] }
   played: null/undefined = all players of the match played (default) */
function scorePlayerAdmin(p, matchPlayers, match) {
  const pKey   = playerKey(p);
  const events = (matchPlayers && matchPlayers.events) || [];
  const played = matchPlayers && matchPlayers.played;
  // null/undefined played = all played; explicit array = only listed players
  if (Array.isArray(played) && !played.includes(pKey)) return 0;

  let pts = 0;
  for (const e of events.filter(ev => ev.playerKey === pKey)) {
    switch (e.type) {
      case 'goal':        pts += SCORING.goal;     break;
      case 'assist':      pts += SCORING.assist;   break;
      case 'pen_scored':  pts += SCORING.pen_goal; break;
      case 'pen_missed':  pts += SCORING.pen_miss; break;
      case 'pen_saved':   if (p.role === 'P') pts += SCORING.pen_save; break;
      case 'yellow_card': pts += SCORING.yellow;   break;
      case 'red_card':    pts += SCORING.red;      break;
      case 'own_goal':    pts += SCORING.own_goal; break;
    }
  }

  // Goalkeeper: goals conceded derived from match score
  if (p.role === 'P' && match.homeScore !== null && match.awayScore !== null) {
    const isHome = p.team === match.home;
    const gc = isHome ? (match.awayScore || 0) : (match.homeScore || 0);
    pts += gc * SCORING.goal_conceded;
    if (gc === 0) pts += SCORING.clean_sheet;
  }

  // Win/loss bonus
  if (match.homeScore !== null && match.awayScore !== null) {
    const isHome = p.team === match.home;
    const mine = isHome ? match.homeScore : match.awayScore;
    const opp  = isHome ? match.awayScore : match.homeScore;
    if (mine > opp)  pts += SCORING.win;
    else if (mine < opp) pts += SCORING.loss;
  }

  return pts;
}

async function recalculateAllScores(round) {
  const roundDrafts = [...(_allDrafts[round] || [])];
  const roundMd = (_matchData[round]) || {};

  roundDrafts.forEach(draft => {
    const slotted  = draft.breakdown || [];
    const ct       = draft.ct || {};
    const userFDef = FORMATIONS[draft.formation || '4-3-3'];
    const ctDCA    = parseDCA(ct.formation || '');
    const ctMulti  = (ctDCA && userFDef && userFDef.d===ctDCA.d && userFDef.c===ctDCA.c && userFDef.a===ctDCA.a)
      ? CT_MULTIPLIER : 1.0;
    let rawTotal = 0;
    draft.breakdown = slotted.map(p => {
      const match = getAdminMatchForTeam(p.team, roundMd);
      const mp    = match ? (match.players || {}) : {};
      const pts   = match ? scorePlayerAdmin(p, mp, match) : 0;
      const isCap = playerKey(p) === draft.captainKey;
      const finalPts = parseFloat((isCap ? pts * CAPTAIN_FACTOR : pts).toFixed(1));
      rawTotal += finalPts;
      return { ...p, pts, finalPts, isCaptain: isCap };
    });
    draft.score          = parseFloat((rawTotal * ctMulti).toFixed(1));
    draft.ctBonusApplied = ctMulti > 1;
  });

  roundDrafts.sort((a, b) => b.score - a.score);
  _allDrafts[round] = roundDrafts;

  // Write updated scores back to Supabase
  for (const draft of roundDrafts) {
    const { error } = await sb.from('drafts')
      .update({
        score:           draft.score,
        picks:           draft.breakdown,
        ct_bonus_applied: draft.ctBonusApplied,
        updated_at:      new Date().toISOString(),
      })
      .eq('round', round)
      .eq('nickname', draft.nick);
    if (error) console.error('recalc update error:', error);
  }
}

function calcPerfectXIAdmin(round) {
  const md       = getMatchData();
  const roundMd  = md[round] || {};
  const roundTeams = getRoundTeams();
  const allPlayers = [];
  for (const sq of DATA.squads) {
    if (!roundTeams.has(sq.team)) continue;
    for (const p of sq.players) {
      const match = getAdminMatchForTeam(sq.team, roundMd);
      const mp    = match ? (match.players || {}) : {};
      const pts   = match ? scorePlayerAdmin({...p, team: sq.team}, mp, match) : 0;
      allPlayers.push({...p, team: sq.team, flag: sq.flag, pts});
    }
  }
  const byRole = {P:[],D:[],C:[],A:[]};
  for (const p of allPlayers) (byRole[p.role]||[]).push(p);
  for (const r in byRole) byRole[r].sort((a,b)=>b.pts-a.pts);
  let bestScore=-Infinity, bestPlayers=[];
  for (let d=3;d<=5;d++) for (let c=2;c<=7;c++) {
    const a=10-d-c;
    if (a<1||a>5) continue;
    if (byRole.P.length<1||byRole.D.length<d||byRole.C.length<c||byRole.A.length<a) continue;
    const combo=[...byRole.P.slice(0,1),...byRole.D.slice(0,d),...byRole.C.slice(0,c),...byRole.A.slice(0,a)];
    const score=combo.reduce((s,p)=>s+p.pts,0);
    if (score>bestScore){bestScore=score;bestPlayers=combo;}
  }
  return {players:bestPlayers, total:parseFloat(bestScore.toFixed(1))};
}

/* ============================================================
   RENDER CORE
   ============================================================ */
function render(html) {
  document.getElementById('app').innerHTML = html;
  updateDesktopUI();
}
function showToast(msg, dur=2200) {
  document.querySelector('.toast')?.remove();
  const el = document.createElement('div');
  el.className='toast'; el.textContent=msg;
  document.body.appendChild(el);
  gsap.fromTo(el,{opacity:0,y:10},{opacity:1,y:0,duration:0.2});
  setTimeout(()=>gsap.to(el,{opacity:0,y:-8,duration:0.2,onComplete:()=>el.remove()}),dur);
}
function animIn(sel) {
  gsap.fromTo(sel,{opacity:0,y:20},{opacity:1,y:0,duration:0.35,ease:'power2.out'});
}

/* ============================================================
   RESTORE BANNER
   ============================================================ */
function restoreBannerHtml(phase) {
  if (!S.restored) return '';
  const canRetry = !S.retryUsed || DEV_MODE;
  const msg = phase === 'formation'
    ? 'Squadra ripristinata — modifica o conferma la formazione'
    : `Draft ripristinato — pick ${Math.max(0, S.pickIndex - 1)} di ${PICK_TOTAL}`;
  return `
    <div style="background:#0a2248;border:1px solid var(--border-hi);border-radius:8px;padding:8px 12px;
                display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;flex:none;">
      <span style="font-size:12px;color:#90aac8;">${msg}</span>
      <button style="background:none;border:none;color:${canRetry?'var(--gold)':'var(--muted2)'};
              font-size:12px;font-family:var(--font-body);padding:0;cursor:${canRetry?'pointer':'default'};"
        ${canRetry?'onclick="doRetry()"':'disabled'}>Ricomincia</button>
    </div>`;
}

/* ============================================================
   HOME SCREEN
   ============================================================ */
function showHome() {
  const completed = DEV_MODE ? null : getCompletedDraft(CURRENT_ROUND);
  const rs        = getRoundState();
  const roundState = rs.roundState;
  const allDraftsRound = getAllDrafts()[CURRENT_ROUND] || [];
  const showScore = roundState !== 'upcoming';
  const rawLb = roundState === 'upcoming'
    ? [...allDraftsRound].sort((a,b)=>(a.ts||0)-(b.ts||0))
    : [...allDraftsRound];
  const lb        = rawLb.slice(0,5);
  const roundName = ROUND_NAMES[CURRENT_ROUND];
  const liveBadge = roundState === 'live'
    ? `<span style="background:var(--bad);color:#fff;font-family:var(--font-title);font-size:9px;font-weight:700;
                    padding:1px 6px;border-radius:4px;letter-spacing:1px;margin-left:6px;vertical-align:middle;">LIVE</span>` : '';
  const lbSection = lb.length===0?'': `
    <div class="section-head mt-20">Classifica ${esc(roundName)}${liveBadge}</div>
    <div class="flex-col gap-8">
      ${lb.map((e,i)=>`
        <div class="lb-row">
          <span class="lb-rank ${i<3?'top3':''}">${i+1}</span>
          <span class="lb-nick">${esc(e.nick)}</span>
          <span class="lb-pts">${showScore ? `${e.score} pts` : '—'}</span>
        </div>`).join('')}
    </div>
    <button class="btn btn-ghost w-full" style="margin-top:8px;font-size:12px;" onclick="showLeaderboard()">Classifica completa →</button>`;
  const cta = completed
    ? `<button class="btn btn-primary" onclick="showResult(true)">Vedi il tuo risultato</button>
       <button class="btn btn-ghost mt-8 w-full" style="margin-top:8px" onclick="startNewDraft()">↺ Nuovo Draft</button>
       <button class="btn btn-ghost w-full" style="margin-top:6px;font-size:12px;" onclick="showLeaderboard()">Classifica completa →</button>`
    : `<button class="btn btn-primary" onclick="startDraft()">Inizia il Draft</button>
       <button class="btn btn-ghost w-full" style="margin-top:8px;font-size:12px;" onclick="showLeaderboard()">Classifica →</button>`;
  render(`
    <div class="screen" id="s-home">
      <div style="margin-top:8px;">
        <div class="eyebrow">Mondiale 2026</div>
        <div class="title" style="margin-top:4px;">FANTA<span style="color:var(--gold)">PICK</span><br>WC26</div>
        <div class="subtitle" style="margin-top:10px;">Scegli il CT e i tuoi <b style="color:var(--text)">11 giocatori</b> per i <b style="color:var(--text)">${esc(roundName)}</b>. Massimizza il punteggio.</div>
      </div>
      <div style="margin-top:auto;padding-top:32px;" class="flex-col">${cta}</div>
      ${lbSection}
    </div>`);
  animIn('#s-home');
}

/* ============================================================
   DRAFT FLOW
   ============================================================ */
function startDraft() {
  if (!getNickname()) { showNicknamePrompt(()=>{ initDraftState(); showPickCT(); }); return; }
  initDraftState(); showPickCT();
}
function startNewDraft() { initDraftState(); showPickCT(); }

function initDraftState() {
  clearDraftState();
  const seedParam = DEV_MODE && new URLSearchParams(location.search).get('seed');
  S.draftSeed = seedParam || (Date.now().toString(36) + Math.random().toString(36).slice(2));
  S.playerPool = buildPlayerPool();
  S.usedKeys = new Set();
  const rng = mkRng(S.draftSeed);
  S.pools = generateAllPools(rng);
  S.swapPools = [];
  S.activeSwapPool = null;
  S.pickIndex = 0;
  S.ctOptions = S.pools[0]?.candidates || getCtOptions();
  S.selectedCT = null;
  S.drafted = []; S.candidatesCache = null; S.retryUsed = false; S.resultData = null;
  S.formation = '4-3-3'; S.slotAssign = Array(11).fill(null);
  S.selectedBench = null; S.captainKey = null;
  S.swapsLeft = 3; S.swapTargetSlotIdx = null; S.restored = false;
}

function showNicknameScreen() {
  return new Promise(resolve => {
    render(`
      <div class="screen nickname-screen" id="s-nickname">
        <div style="text-align:center;">
          <div class="eyebrow">Mondiale 2026</div>
          <div class="title" style="margin-top:4px;">FANTA<span style="color:var(--gold)">PICK</span><br>WC26</div>
        </div>
        <div style="text-align:center;">
          <div style="font-family:var(--font-title);font-size:30px;font-weight:900;line-height:1.1;">Come ti chiami?</div>
          <div class="subtitle" style="margin-top:6px;">Il tuo nickname apparirà in classifica.</div>
        </div>
        <input id="nick-screen-input" type="text" maxlength="20" placeholder="Es. Tifoso_Milano"
          class="nick-screen-input"
          autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false">
        <span class="nick-screen-hint" id="nick-screen-hint"></span>
        <button id="nick-screen-btn" class="btn btn-primary" disabled>Inizia →</button>
      </div>`);
    animIn('#s-nickname');
    const input = document.getElementById('nick-screen-input');
    const btn   = document.getElementById('nick-screen-btn');
    const hint  = document.getElementById('nick-screen-hint');
    setTimeout(() => input?.focus(), 350);
    input.addEventListener('input', () => {
      const v = validateNickname(input.value.trim());
      btn.disabled = !v.ok;
      hint.textContent = v.message;
      hint.className = 'nick-screen-hint ' + (v.ok ? 'ok' : 'err');
    });
    input.addEventListener('keydown', e => { if (e.key === 'Enter' && !btn.disabled) btn.click(); });
    btn.addEventListener('click', () => { setNickname(input.value.trim()); resolve(); });
  });
}
/* kept for any legacy callers — delegates to showNicknameScreen then cb */
function showNicknamePrompt(cb) { showNicknameScreen().then(cb); }
function submitNickname() { /* no-op — handled inside showNicknameScreen */ }

/* ============================================================
   CT PICK
   ============================================================ */
function showPickCT() {
  S.pickIndex=0;
  render(`
    <div class="screen" id="s-ct">
      ${headerHtml(0)}
      <div class="eyebrow" style="margin-top:20px;">Scegli il Commissario Tecnico</div>
      <div class="subtitle" style="margin-bottom:16px;">La sua formazione è il tuo schema. Bonus <b style="color:var(--gold)">×1.25</b> se lo rispetti alla fine.</div>
      <div class="flex-col gap-8" id="ct-list">
        ${S.ctOptions.map((ct,i)=>`
          <button class="ct-card" id="ctc-${i}" onclick="pickCT(${i})">
            <span class="ct-flag">${esc(ct.flag)}</span>
            <div class="ct-info">
              <div class="ct-name">${esc(ct.name)}</div>
              <div class="ct-team">${esc(ct.team)}</div>
            </div>
            <span class="ct-formation">${esc(ct.formation)}</span>
          </button>`).join('')}
      </div>
      ${retryBarHtml()}
    </div>`);
  animIn('#s-ct');
  gsap.from('#ct-list .ct-card',{opacity:0,y:18,stagger:0.08,duration:0.3,delay:0.1});
}
function pickCT(i) {
  S.selectedCT=S.ctOptions[i]; S.pickIndex=1; S.candidatesCache=null;
  saveDraftState('draft');
  const card=document.getElementById(`ctc-${i}`);
  if (card){card.classList.add('selected');gsap.to(card,{scale:1.04,duration:0.12,yoyo:true,repeat:1,onComplete:showPickPlayer});}
  else showPickPlayer();
}

/* ============================================================
   PLAYER PICK
   ============================================================ */
function showPickPlayer() {
  const cands=getCandidates(), rc=roleCounts(), fr=forcedRoles(), pickN=S.pickIndex;
  const hint=fr.length>0
    ?`<div class="role-hint mt-8"><b>Ruolo obbligatorio: ${fr.slice(0,1).map(roleName).join(', ')}</b> — pick rimanenti: ${PICK_TOTAL-S.drafted.length}</div>`:'';
  render(`
    <div class="screen" id="s-pick">
      ${restoreBannerHtml('draft')}
      ${headerHtml(pickN)}
      <div class="flex items-center justify-between" style="margin-top:16px;margin-bottom:4px;">
        <div>
          <div class="eyebrow">Pick ${pickN} di ${PICK_TOTAL}</div>
          <div style="font-family:var(--font-title);font-size:12px;color:var(--muted);margin-top:2px;">
            CT: <b style="color:var(--text)">${esc(S.selectedCT.name)}</b>
            — <span style="color:var(--gold)">${esc(S.selectedCT.formation)}</span>
          </div>
        </div>
        <div style="display:flex;gap:8px;font-family:var(--font-title);font-size:11px;letter-spacing:1px;">
          <span style="color:var(--role-p)">P:${rc.P}</span>
          <span style="color:var(--role-d)">D:${rc.D}</span>
          <span style="color:var(--role-c)">C:${rc.C}</span>
          <span style="color:var(--role-a)">A:${rc.A}</span>
        </div>
      </div>
      ${hint}
      <div class="pick-grid" id="cards-grid" style="margin-top:10px;gap:8px;">
        ${cands.map((p,i)=>playerCardHtml(p,i)).join('')}
      </div>
      ${S.drafted.length>0?draftedMiniHtml():''}
      ${retryBarHtml()}
    </div>`);
  animIn('#s-pick');
  gsap.from('#cards-grid .pick-card-h',{opacity:0,y:14,stagger:0.07,duration:0.28,delay:0.05});
}
function playerCardHtml(p, i) {
  const fix = getPlayerFixture(p);
  const parts = p.name.split(' ');
  const surname = parts[parts.length - 1];
  const firstName = parts.slice(0, -1).join(' ');
  return `
    <div class="pick-card-h" id="cand-${i}" onclick="pickPlayer(${i})">
      <div class="pch-left">
        <span class="pch-flag">${esc(p.flag)}</span>
        <span class="role-badge ${roleClass(p.role)}">${roleName(p.role)}</span>
      </div>
      <div class="pch-center">
        ${firstName ? `<div class="pch-firstname">${esc(firstName)}</div>` : ''}
        <div class="pch-surname">${esc(surname)}</div>
        ${starsHtml(p.stars)}
      </div>
      ${fix ? `<div class="pch-fix">${esc(fix)}</div>` : ''}
    </div>`;
}
function pickPlayer(i) {
  const chosen=getCandidates()[i];
  if (!chosen) return;
  S.drafted.push(chosen); S.usedKeys.add(playerKey(chosen));
  S.candidatesCache=null; S.pickIndex++;
  saveDraftState(S.drafted.length>=PICK_TOTAL ? 'formation' : 'draft');
  const grid=document.getElementById('cards-grid');
  if (grid) grid.querySelectorAll('.pick-card-h').forEach((c,idx)=>{
    gsap.to(c, idx===i?{scale:1.04,duration:0.12,yoyo:true,repeat:1}:{opacity:0.2,duration:0.2});
  });
  setTimeout(()=> S.drafted.length>=PICK_TOTAL ? showFormationScreen() : showPickPlayer(), 320);
}
function draftedMiniHtml() {
  return `
    <div class="drafted-mini mt-12">
      ${S.drafted.map(p=>`
        <div class="drafted-mini-row">
          <span class="role-badge ${roleClass(p.role)}" style="font-size:9px;">${roleName(p.role)}</span>
          <span style="font-size:12px;">${esc(p.flag)}</span>
          <span class="drafted-mini-name">${esc(p.name)}</span>
        </div>`).join('')}
    </div>`;
}

/* ============================================================
   HEADER & RETRY
   ============================================================ */
function headerHtml(pickN) {
  const total=PICK_TOTAL+1, pct=Math.round((pickN/total)*100);
  const dots=Array.from({length:total},(_,i)=>{
    const cls=i<pickN?'pick-dot done':(i===0&&pickN>0?'pick-dot ct':'pick-dot');
    return `<div class="${cls}"></div>`;
  }).join('');
  return `
    <div class="progress-wrap">
      <div class="progress-label">
        <span>${pickN===0?'Scelta CT':`Pick ${pickN}/${PICK_TOTAL}`}</span>
        <span>${pct}%</span>
      </div>
      <div class="progress-track"><div class="progress-fill" style="width:${pct}%"></div></div>
      <div class="pick-dots">${dots}</div>
    </div>`;
}
function retryBarHtml() {
  if (S.retryUsed) return `<div class="flex items-center" style="margin-top:12px;gap:8px;"><span class="section-head" style="margin:0;">Retry</span><span class="retry-badge used">USATO</span></div>`;
  return `
    <div class="flex items-center justify-between" style="margin-top:12px;">
      <span class="section-head" style="margin:0;">1 Retry disponibile</span>
      <button class="btn btn-ghost" onclick="doRetry()" style="font-size:12px;padding:8px 12px;">↺ Ricomincia</button>
    </div>`;
}
function doRetry() {
  if (S.retryUsed && !DEV_MODE){showToast('Retry già usato!');return;}
  initDraftState();
  if (!DEV_MODE) S.retryUsed=true;
  showToast('Draft azzerato!'); showPickCT();
}

/* ============================================================
   FORMATION SCREEN
   ============================================================ */
function showFormationScreen() {
  S.swapTargetSlotIdx=null;
  S.selectedBench=null;
  const fd=FORMATIONS[S.formation], ct=S.selectedCT;
  const mct=getMatchForTeam(ct.team);
  const ctFormUsed=mct?(mct.home===ct.team?mct.formation_home:mct.formation_away):ct.formation;
  const ctDCA=parseDCA(ctFormUsed);
  const bonusOk=ctDCA&&fd.d===ctDCA.d&&fd.c===ctDCA.c&&fd.a===ctDCA.a;
  const rc=roleCounts(), filled=S.slotAssign.filter(Boolean).length, valid=isFormationValid();
  const swapBadge=S.swapsLeft>0
    ?`<span style="font-family:var(--font-title);font-size:11px;color:var(--muted);border:1px solid var(--border);padding:2px 7px;border-radius:6px;cursor:default;">⇄ ${S.swapsLeft}</span>`
    :`<span style="font-family:var(--font-title);font-size:10px;color:var(--muted2);text-decoration:line-through;">⇄ 0</span>`;

  render(`
    <div class="screen" id="s-formation" style="padding-bottom:24px;">
      ${restoreBannerHtml('formation')}
      <div class="eyebrow">Formazione</div>
      <div class="flex items-center justify-between" style="margin:4px 0 10px;">
        <div style="font-size:11px;color:var(--muted);">
          CT: <b style="color:var(--text)">${esc(ct.name)}</b>
          &nbsp;·&nbsp;<span style="color:var(--gold)">${esc(ctFormUsed)}</span>
          ${bonusOk?'<span style="color:var(--good)"> ✓ ×1.25</span>':''}
        </div>
        <div style="display:flex;gap:8px;align-items:center;">
          <div style="display:flex;gap:5px;font-family:var(--font-title);font-size:10px;">
            <span style="color:var(--role-p)">P:${rc.P}</span>
            <span style="color:var(--role-d)">D:${rc.D}</span>
            <span style="color:var(--role-c)">C:${rc.C}</span>
            <span style="color:var(--role-a)">A:${rc.A}</span>
          </div>
          ${swapBadge}
        </div>
      </div>

      <div class="formation-tabs" id="form-tabs">
        ${FORMATION_LIST.map(f=>`
          <button class="formation-tab ${f===S.formation?'active':''}" onclick="selectFormation('${f}')">${f}</button>
        `).join('')}
      </div>

      <div class="pitch-wrap" id="pitch" style="min-height:272px;margin-top:8px;flex:none;">
        ${pitchSvg()}
        ${fd.slots.map((slot,i)=>slotNodeHtml(slot,i)).join('')}
      </div>

      <div class="flex items-center justify-between" style="margin-top:10px;">
        <div class="section-head" style="margin:0;">Panchina</div>
        <div id="cap-status" style="font-size:11px;color:${S.captainKey?'var(--good)':'var(--muted)'};">
          ${S.captainKey?'👑 Capitano impostato':'Tocca slot pieno → Capitano'}
        </div>
      </div>
      <div class="bench-strip" id="bench" style="margin-top:6px;">
        ${S.drafted.map((p,i)=>benchPlayerHtml(p,i)).join('')}
      </div>
      <div class="subtitle" style="margin-top:6px;font-size:11px;">
        Seleziona dalla panchina → tocca slot compatibile. Slot vuoto senza giocatori → Swap Draft.
      </div>

      <button class="btn btn-primary" id="confirm-btn" ${valid?'':'disabled'}
        onclick="confirmFormation()" style="margin-top:10px;flex:none;">
        ${valid?'Conferma e Calcola →':`${filled}/11 slot${S.captainKey?'':' · scegli capitano'}`}
      </button>
      ${S.retryUsed?'':`<button class="btn btn-ghost w-full" style="margin-top:8px;flex:none;" onclick="doRetry()">↺ Retry draft</button>`}
    </div>`);

  animIn('#s-formation');
  gsap.from('#pitch .slot-node',{opacity:0,scale:0.4,stagger:0.03,duration:0.35,delay:0.1,ease:'back.out(1.5)'});
}

/* -------- slot & bench rendering -------- */
function isAssigned(p) {
  const key=playerKey(p);
  return S.slotAssign.some(sp=>sp&&playerKey(sp)===key);
}

function slotNodeHtml(slot, slotIdx) {
  const p=S.slotAssign[slotIdx];
  const [px,py]=slot.pos;
  const roleColorMap={P:'var(--role-p)',D:'var(--role-d)',C:'var(--role-c)',A:'var(--role-a)'};
  if (!p) {
    // Check if there are any unassigned bench players of this role
    const hasCandidate = S.drafted.some(d => d.role===slot.r && !isAssigned(d));
    const emptyStyle = hasCandidate
      ? `border-color:${roleColorMap[slot.r]}35;color:${roleColorMap[slot.r]}55;border-style:dashed;`
      : (S.swapsLeft>0
          ? `border-color:var(--gold)30;color:var(--gold)60;border-style:dashed;`
          : `border-color:var(--bad)25;color:var(--bad)40;border-style:dashed;`);
    const swapHint = !hasCandidate && S.swapsLeft>0
      ? `<span style="position:absolute;top:-10px;font-size:9px;color:var(--gold);font-family:var(--font-title);">⇄</span>` : '';
    return `
      <div class="slot-node" id="slot-${slotIdx}" style="left:${px}%;top:${py}%;" onclick="tapSlot(${slotIdx})">
        <div class="slot-circle" style="${emptyStyle}position:relative;">
          ${swapHint}
          <span style="font-size:9px;">${roleName(slot.r)}</span>
        </div>
        <div class="slot-label" style="opacity:0.4">—</div>
      </div>`;
  }
  const isCap=playerKey(p)===S.captainKey;
  const fClass={P:'filled-p',D:'filled-d',C:'filled-c',A:'filled-a'}[p.role]||'';
  return `
    <div class="slot-node" id="slot-${slotIdx}" style="left:${px}%;top:${py}%;" onclick="tapSlot(${slotIdx})">
      <div class="slot-circle filled ${fClass} ${isCap?'captain-slot':''}">
        ${isCap?'<span class="slot-crown">👑</span>':''}
        <span style="font-size:10px;">${roleName(p.role)}</span>
        <button class="slot-remove" onclick="event.stopPropagation();removeFromSlot(${slotIdx})">×</button>
      </div>
      <div class="slot-label">${esc(p.name.split(' ').pop())}</div>
    </div>`;
}

function benchPlayerHtml(p, i) {
  const assigned=isAssigned(p), selected=S.selectedBench===i;
  return `
    <div class="bench-player ${selected?'selected':''} ${assigned?'assigned':''}"
         id="bench-${i}" onclick="tapBench(${i})">
      <span class="role-badge ${roleClass(p.role)}" style="font-size:9px;padding:1px 5px;">${roleName(p.role)}</span>
      <span style="font-size:13px;line-height:1;">${esc(p.flag)}</span>
      <span class="bench-player-name">${esc(p.name.split(' ').pop())}</span>
    </div>`;
}

/* -------- formation interaction -------- */
function selectFormation(key) {
  if (S.formation===key) return;
  S.formation=key; S.slotAssign=Array(11).fill(null); S.selectedBench=null; S.captainKey=null;
  saveDraftState('formation');
  showFormationScreen();
}

function tapBench(i) {
  const p=S.drafted[i];
  if (!p||isAssigned(p)) return;
  S.selectedBench=(S.selectedBench===i)?null:i;
  document.querySelectorAll('.bench-player').forEach((el,idx)=>{
    el.classList.toggle('selected',idx===S.selectedBench);
  });
}

function tapSlot(slotIdx) {
  const slot=FORMATIONS[S.formation].slots[slotIdx];
  const cur=S.slotAssign[slotIdx];

  if (cur) {
    // Filled slot → toggle captain
    const key=playerKey(cur);
    S.captainKey=(S.captainKey===key)?null:key;
    updateAllSlots();
    const cs=document.getElementById('cap-status');
    if (cs){cs.style.color=S.captainKey?'var(--good)':'var(--muted)';
            cs.textContent=S.captainKey?'👑 Capitano impostato':'Tocca slot pieno → Capitano';}
    updateConfirmBtn();
    if (S.captainKey===key){
      const circle=document.querySelector(`#slot-${slotIdx} .slot-circle`);
      if (circle) gsap.fromTo(circle,{scale:1},{scale:1.28,duration:0.14,yoyo:true,repeat:1});
    }
    saveDraftState('formation');
    return;
  }

  // Empty slot
  if (S.selectedBench!==null) {
    const bp=S.drafted[S.selectedBench];
    if (!bp){S.selectedBench=null;return;}
    if (bp.role!==slot.r) {
      showToast('Ruolo incompatibile!');
      const circle=document.querySelector(`#slot-${slotIdx} .slot-circle`);
      if (circle){
        circle.style.borderColor='var(--bad)';circle.style.background='rgba(239,68,68,0.2)';
        setTimeout(()=>{circle.style.borderColor='';circle.style.background='';},500);
      }
      return;
    }
    S.slotAssign[slotIdx]=bp; S.selectedBench=null;
    updateAllSlots(); updateBench(); updateConfirmBtn();
    saveDraftState('formation');
    return;
  }

  // No bench selection → Swap Draft
  if (S.swapsLeft<=0) {
    showToast('Swap esauriti! Usa ↺ Retry per un nuovo draft.');
    return;
  }
  showSlotDrawer(slotIdx);
}

function removeFromSlot(slotIdx) {
  const p=S.slotAssign[slotIdx];
  if (!p) return;
  if (S.captainKey===playerKey(p)) S.captainKey=null;
  S.slotAssign[slotIdx]=null;
  updateAllSlots(); updateBench(); updateConfirmBtn();
  saveDraftState('formation');
}

function updateAllSlots() {
  FORMATIONS[S.formation].slots.forEach((slot,i)=>{
    const el=document.getElementById(`slot-${i}`);
    if (el) el.outerHTML=slotNodeHtml(slot,i);
  });
}
function updateBench() {
  const b=document.getElementById('bench');
  if (b) b.innerHTML=S.drafted.map((p,i)=>benchPlayerHtml(p,i)).join('');
}
function updateConfirmBtn() {
  const btn=document.getElementById('confirm-btn');
  if (!btn) return;
  const valid=isFormationValid(), filled=S.slotAssign.filter(Boolean).length;
  btn.disabled=!valid;
  btn.textContent=valid?'Conferma e Calcola →':`${filled}/11 slot${S.captainKey?'':' · scegli capitano'}`;
}
function isFormationValid() {
  if (S.slotAssign.some(p=>!p)) return false;
  if (!S.captainKey) return false;
  return S.slotAssign.some(p=>p&&playerKey(p)===S.captainKey);
}

/* ============================================================
   SWAP DRAFT  — starts from empty slot tap
   ============================================================ */


function showSlotDrawer(slotIdx) {
  const targetRole=FORMATIONS[S.formation].slots[slotIdx].r;
  S.swapTargetSlotIdx=slotIdx;
  const frame=document.getElementById('frame');

  const overlay=document.createElement('div');
  overlay.id='swap-overlay';
  overlay.style.cssText='position:absolute;inset:0;z-index:50;display:flex;flex-direction:column;justify-content:flex-end;background:rgba(0,0,0,0);';
  overlay.addEventListener('click', e=>{ if(e.target===overlay) closeSwapDrawer(); });
  overlay.innerHTML=`
    <div id="swap-drawer-panel" style="position:relative;background:var(--bg);border-radius:24px 24px 0 0;
         padding:20px 18px 40px;max-height:80vh;overflow-y:auto;-webkit-overflow-scrolling:touch;">
      <div style="width:36px;height:4px;background:var(--border);border-radius:2px;margin:0 auto 16px;"></div>
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:4px;">
        <div>
          <div style="font-family:var(--font-title);font-size:11px;font-weight:700;letter-spacing:2px;color:var(--gold);text-transform:uppercase;">
            Slot <span class="role-badge ${roleClass(targetRole)}" style="margin-left:4px;">${roleName(targetRole)}</span>
          </div>
          <div style="font-size:12px;color:var(--muted);margin-top:5px;">✓ gratis · ⇄ consuma 1 swap</div>
        </div>
        <span style="font-family:var(--font-title);font-size:14px;font-weight:700;color:${S.swapsLeft>0?'var(--gold)':'var(--muted2)'};">⇄ ${S.swapsLeft}</span>
      </div>
      <div class="flex-col" id="slot-drawer-list" style="margin-top:12px;">
        ${S.drafted.map((p,i)=>slotDrawerRowHtml(p,i,slotIdx)).join('')}
      </div>
      <button class="btn btn-ghost w-full" style="margin-top:16px;" onclick="closeSwapDrawer()">Annulla</button>
    </div>`;
  frame.appendChild(overlay);

  const panel=document.getElementById('swap-drawer-panel');
  gsap.fromTo(panel,{y:'100%'},{y:0,duration:0.35,ease:'power3.out'});
  gsap.fromTo(overlay,{opacity:0},{opacity:1,duration:0.25});
}

function slotDrawerRowHtml(p, i, slotIdx) {
  const targetRole=FORMATIONS[S.formation].slots[slotIdx].r;
  const canMove=p.role===targetRole;
  const moveBtn=canMove
    ?`<button class="btn btn-ghost" style="flex:none;font-size:11px;padding:5px 9px;border-color:var(--good);color:var(--good);"
        onclick="assignFromDrawer(${i},${slotIdx})">✓</button>`:'';
  const swapBtn=S.swapsLeft>0
    ?`<button class="btn btn-ghost" style="flex:none;font-size:11px;padding:5px 9px;border-color:var(--bad);color:var(--bad);"
        onclick="executeSacrifice(${i},${slotIdx})">⇄</button>`:'';
  return `
    <div class="swap-drawer-row" id="sdr-${i}">
      <span class="role-badge ${roleClass(p.role)}">${roleName(p.role)}</span>
      <span style="font-size:14px;">${esc(p.flag)}</span>
      <span style="flex:1;font-size:13px;font-weight:500;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;color:#CBD5E0;">${esc(p.name)}</span>
      <div style="display:flex;gap:4px;flex:none;">${moveBtn}${swapBtn}</div>
    </div>`;
}

function assignFromDrawer(draftedIdx, slotIdx) {
  const player=S.drafted[draftedIdx];
  if (!player) return;
  const old=S.slotAssign.findIndex(sp=>sp&&playerKey(sp)===playerKey(player));
  if (old>=0) S.slotAssign[old]=null;
  S.slotAssign[slotIdx]=player;
  S.selectedBench=null;
  closeSwapDrawer();
  saveDraftState('formation');
  setTimeout(()=>{ updateAllSlots(); updateBench(); updateConfirmBtn(); },260);
}

function closeSwapDrawer() {
  S.swapTargetSlotIdx=null;
  const panel=document.getElementById('swap-drawer-panel');
  const overlay=document.getElementById('swap-overlay');
  if (panel) {
    gsap.to(panel,{y:'100%',duration:0.25,ease:'power2.in',
      onComplete:()=>overlay?.remove()});
    gsap.to(overlay,{opacity:0,duration:0.2});
  } else overlay?.remove();
}

function executeSacrifice(draftedIdx, slotIdx) {
  const sacrificed=S.drafted[draftedIdx];
  if (!sacrificed) return;

  const rowEl=document.getElementById(`sdr-${draftedIdx}`);
  const proceed=()=>{
    // Remove player from squad
    S.drafted=S.drafted.filter((_,i)=>i!==draftedIdx);
    S.usedKeys.add(playerKey(sacrificed));
    // Free their assigned slot if any
    const assignedIdx=S.slotAssign.findIndex(sp=>sp&&playerKey(sp)===playerKey(sacrificed));
    if (assignedIdx>=0) S.slotAssign[assignedIdx]=null;
    // Clear captain if sacrificed
    if (S.captainKey===playerKey(sacrificed)) S.captainKey=null;
    S.swapsLeft--;
    S.swapTargetSlotIdx=slotIdx;
    // Close drawer and go to pick screen
    document.getElementById('swap-overlay')?.remove();
    showSwapPickPlayer(FORMATIONS[S.formation].slots[slotIdx].r, slotIdx);
  };

  if (rowEl) gsap.to(rowEl,{scale:0.85,opacity:0,x:16,duration:0.22,ease:'power2.in',onComplete:proceed});
  else proceed();
}

function showSwapPickPlayer(role, targetSlotIdx) {
  S.swapTargetSlotIdx = targetSlotIdx;

  // Use existing persisted swap pool if already generated for this swap
  let swapPool = S.activeSwapPool
    ? S.swapPools.find(sp => sp.id === S.activeSwapPool)
    : null;

  if (!swapPool) {
    const swapId = `swap_${S.swapPools.length + 1}`;
    const swapRng = mkRng((S.draftSeed || 'fallback') + '_' + swapId);
    const available = S.playerPool.filter(p => p.role === role && !S.usedKeys.has(playerKey(p)));
    const candidates = shuffleRng(available, swapRng).slice(0, 4);
    swapPool = { id: swapId, slot: role, candidates };
    S.swapPools.push(swapPool);
    S.activeSwapPool = swapId;
    saveDraftState('swappick');
  }

  SWAP_CANDIDATES = swapPool.candidates;

  render(`
    <div class="screen" id="s-swap-pick">
      <div class="eyebrow" style="color:var(--gold);margin-top:8px;">Swap Draft — Scegli</div>
      <div style="margin-top:6px;margin-bottom:16px;display:flex;align-items:center;gap:8px;">
        <div class="subtitle">Nuovo</div>
        <span class="role-badge ${roleClass(role)}">${roleName(role)}</span>
        <div class="subtitle">in rosa</div>
      </div>
      <div style="display:grid;grid-template-columns:1fr 1fr;gap:10px;" id="swap-cards">
        ${SWAP_CANDIDATES.map((p,i)=>`
          <div class="pick-card" id="swc-${i}" onclick="pickSwap(${i})">
            <div class="pick-card-name">${esc(p.name)}</div>
            <div class="pick-card-meta">
              <span class="pick-card-flag">${esc(p.flag)}</span>
              <span class="pick-card-team">${esc(p.team)}</span>
            </div>
            <div style="display:flex;align-items:center;gap:6px;">
              <span class="role-badge ${roleClass(p.role)}">${roleName(p.role)}</span>
              ${starsHtml(p.stars)}
            </div>
          </div>`).join('')}
      </div>
      ${SWAP_CANDIDATES.length===0?`
        <div class="subtitle center mt-20">Nessun giocatore disponibile per questo ruolo.</div>
        <button class="btn btn-ghost w-full" style="margin-top:16px;" onclick="showFormationScreen()">← Torna</button>`:''}
    </div>`);
  animIn('#s-swap-pick');
  gsap.from('#swap-cards .pick-card',{opacity:0,y:18,stagger:0.08,duration:0.3,delay:0.05});
}

function pickSwap(i) {
  const newPlayer=SWAP_CANDIDATES[i];
  if (!newPlayer) return;
  const card=document.getElementById(`swc-${i}`);
  const proceed=()=>{
    S.drafted.push(newPlayer);
    S.usedKeys.add(playerKey(newPlayer));
    if (S.swapTargetSlotIdx!==null) S.slotAssign[S.swapTargetSlotIdx]=newPlayer;
    S.swapTargetSlotIdx=null;
    S.activeSwapPool=null;
    saveDraftState('formation');
    showFormationScreen();
    showToast(`${newPlayer.name} entrato in rosa!`);
  };
  if (card) gsap.to(card,{scale:1.06,duration:0.12,yoyo:true,repeat:1,onComplete:proceed});
  else proceed();
}

/* ============================================================
   CONFIRM → RESULT
   ============================================================ */
function confirmFormation() {
  if (!isFormationValid()){showToast('Completa la formazione e scegli il capitano!');return;}
  const result=computeResult(); S.resultData=result;
  const nick=getNickname()||'Anonimo';
  saveCompletedDraft(CURRENT_ROUND,{
    score:result.total, breakdown:result.breakdown, ct:result.ct,
    captainKey:S.captainKey, ctBonusApplied:result.ctBonusApplied, formation:S.formation,
  });
  // Store with score:0 — admin recalculates real pts later
  const draftEntry = {
    nick,
    score: 0,
    breakdown: result.breakdown.map(p => ({...p, pts:0, finalPts:0})),
    ct: result.ct,
    formation: S.formation,
    captainKey: S.captainKey,
    ctBonusApplied: false,
    swapsUsed: Math.max(0, 3 - (S.swapsLeft ?? 3)),
    retryUsed: S.retryUsed || false,
    ts: Date.now(),
  };
  // Update local cache immediately so result screen works offline
  _allDrafts[CURRENT_ROUND] = _allDrafts[CURRENT_ROUND] || [];
  const idx = _allDrafts[CURRENT_ROUND].findIndex(d => d.nick === draftEntry.nick);
  if (idx >= 0) _allDrafts[CURRENT_ROUND][idx] = draftEntry; else _allDrafts[CURRENT_ROUND].push(draftEntry);
  saveDraftState('result');
  showResult(false);
  // Async Supabase submit — non-blocking
  submitDraftToSupabase(CURRENT_ROUND, draftEntry);
}

/* ============================================================
   PITCH SVG
   ============================================================ */
function pitchSvg() {
  return `
    <svg style="position:absolute;inset:0;width:100%;height:100%;opacity:0.12;pointer-events:none;"
         viewBox="0 0 100 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg">
      <rect x="2" y="2" width="96" height="96" rx="1" fill="none" stroke="#fff" stroke-width="0.5"/>
      <line x1="2" y1="50" x2="98" y2="50" stroke="#fff" stroke-width="0.4"/>
      <circle cx="50" cy="50" r="10" fill="none" stroke="#fff" stroke-width="0.4"/>
      <rect x="27" y="80" width="46" height="18" fill="none" stroke="#fff" stroke-width="0.4"/>
      <rect x="37" y="90" width="26" height="10" fill="none" stroke="#fff" stroke-width="0.4"/>
      <rect x="27" y="2"  width="46" height="18" fill="none" stroke="#fff" stroke-width="0.4"/>
      <rect x="37" y="2"  width="26" height="10" fill="none" stroke="#fff" stroke-width="0.4"/>
    </svg>`;
}

/* ============================================================
   RESULT SCREEN
   ============================================================ */
function showResult(fromStorage) {
  const rs         = getRoundState();
  const roundState = rs.roundState;
  const nick       = getNickname();

  // Prefer admin-computed data from all_drafts
  const allDraftsRound = getAllDrafts()[CURRENT_ROUND] || [];
  const adminDraft     = nick ? allDraftsRound.find(d => d.nick === nick) : null;

  let result = S.resultData;
  if (fromStorage || !result) {
    const saved = getCompletedDraft(CURRENT_ROUND);
    if (!saved && !adminDraft) { showHome(); return; }
    const base = adminDraft || saved;
    result = { total: base.score || 0, breakdown: base.breakdown || [], ct: base.ct, ctBonusApplied: base.ctBonusApplied || false };
    S.resultData = result;
  }

  const displayBreakdown  = adminDraft?.breakdown || result.breakdown;
  const displayScore      = adminDraft?.score ?? (roundState === 'upcoming' ? 0 : result.total);
  const displayCtBonus    = adminDraft?.ctBonusApplied ?? result.ctBonusApplied;
  const isUpcoming        = roundState === 'upcoming';
  const isLive            = roundState === 'live';
  const isCompleted       = roundState === 'completed';
  const roundName         = ROUND_NAMES[CURRENT_ROUND];
  const share             = buildShareText(displayScore, displayBreakdown, roundName);

  const liveBadge = isLive
    ? `<span style="background:var(--bad);color:#fff;font-family:var(--font-title);font-size:10px;font-weight:700;
                    padding:2px 8px;border-radius:5px;letter-spacing:1px;margin-left:10px;">LIVE 🔴</span>` : '';

  const upcomingNote = isUpcoming ? `
    <div style="background:var(--panel);border:1px solid var(--border);border-radius:var(--radius-sm);
                padding:16px;text-align:center;margin:8px 0;">
      <div style="font-size:22px;margin-bottom:8px;">⏳</div>
      <div style="font-size:13px;color:var(--muted);">Le partite non sono ancora iniziate.<br>Il tuo punteggio si aggiornerà in tempo reale.</div>
    </div>` : '';

  let perfectXISection = '';
  if (isCompleted) {
    const pxi = calcPerfectXIAdmin(CURRENT_ROUND);
    perfectXISection = `
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:6px;">
        <div class="section-head" style="margin:0;">Perfect XI</div>
        <span style="font-family:var(--font-title);font-size:16px;color:var(--gold);">${pxi.total} pts</span>
      </div>
      <div class="subtitle" style="margin-bottom:8px;">Il massimo teorico del round.</div>
      <div class="flex-col" style="opacity:0.75;">
        ${pxi.players.map(p=>`
          <div class="breakdown-row">
            <span class="role-badge ${roleClass(p.role)}">${roleName(p.role)}</span>
            <span style="font-size:13px;color:var(--muted);width:22px;">${esc(p.flag)}</span>
            <span class="breakdown-name">${esc(p.name)}</span>
            <span class="breakdown-pts ${ptsCls(p.pts)}">${fmtPts(p.pts)}</span>
          </div>`).join('')}
      </div>
      <div class="divider"></div>`;
  }

  render(`
    <div class="screen" id="s-result">
      <div class="eyebrow center">${esc(roundName)}</div>
      <div class="result-main">

        <div class="result-col-left">
          <div style="margin:12px 0 4px;">
            <div style="display:flex;align-items:center;justify-content:center;">
              <div class="score-big" id="score-anim">0.0</div>
              ${liveBadge}
            </div>
            <div class="score-label">punti totali</div>
            ${displayCtBonus?'<div class="center" style="font-size:12px;color:var(--good);margin-top:6px;">✓ Bonus CT ×1.25 applicato!</div>':''}
          </div>
          ${upcomingNote}
          <div class="divider"></div>
          <div class="section-head">La tua squadra</div>
          <div class="flex-col">${displayBreakdown.map(p=>breakdownRowHtml(p)).join('')}</div>
          <div class="divider"></div>
          <div class="section-head">Condividi</div>
          <div class="share-box" onclick="copyShare()" title="Tocca per copiare">${esc(share)}</div>
          <div style="font-size:11px;color:var(--muted);text-align:center;margin-top:4px;">Tocca per copiare</div>
        </div>

        <div class="result-col-right">
          <div class="divider result-mob-sep"></div>
          ${perfectXISection}
          ${lbHtml()}
          <button class="btn btn-ghost w-full" style="margin-top:16px;" onclick="showHome()">← Torna alla home</button>
        </div>

      </div>
    </div>`);
  animIn('#s-result');
  const scoreEl = document.getElementById('score-anim');
  if (scoreEl) {
    const obj = {val:0};
    gsap.to(obj, {val:displayScore, duration:1.4, ease:'power2.out', delay:0.3, onUpdate:()=>{scoreEl.textContent=obj.val.toFixed(1);}});
  }
  gsap.from('.breakdown-row', {opacity:0, x:-14, stagger:0.05, duration:0.3, delay:0.5});
}

function breakdownRowHtml(p) {
  const pts=p.finalPts!=null?p.finalPts:(p.pts||0);
  return `
    <div class="breakdown-row">
      ${p.isCaptain?'<span style="font-size:14px;flex:none;">👑</span>':''}
      <span class="role-badge ${roleClass(p.role)}">${roleName(p.role)}</span>
      <span style="font-size:13px;color:var(--muted);width:22px;flex:none;">${esc(p.flag||'')}</span>
      <span class="breakdown-name">${esc(p.name)}</span>
      <span class="breakdown-pts ${ptsCls(pts)}">${fmtPts(pts)}</span>
    </div>`;
}
function ptsCls(pts){ return pts>0?'pts-positive':pts<0?'pts-negative':'pts-zero'; }
function fmtPts(pts){ const n=pts||0; return (n>0?'+':'')+n.toFixed(1); }

function lbHtml() {
  const rs         = getRoundState();
  const roundState = rs.roundState;
  const nick       = getNickname();
  const allDraftsRound = getAllDrafts()[CURRENT_ROUND] || [];

  const lb = roundState === 'upcoming'
    ? [...allDraftsRound].sort((a,b) => (a.ts||0) - (b.ts||0))
    : [...allDraftsRound];

  const myI = lb.findIndex(e => e.nick === nick);
  const showScore = roundState !== 'upcoming';
  const liveBadge = roundState === 'live'
    ? `<span style="background:var(--bad);color:#fff;font-family:var(--font-title);font-size:9px;font-weight:700;
                    padding:1px 6px;border-radius:4px;letter-spacing:1px;margin-left:6px;">LIVE</span>` : '';

  return `
    <div class="section-head">Classifica${liveBadge}</div>
    <div class="flex-col gap-8">
      ${lb.slice(0,10).map((e,i)=>`
        <div class="lb-row ${e.nick===nick?'me':''}">
          <span class="lb-rank ${i<3?'top3':''}">${i+1}</span>
          <span class="lb-nick">${esc(e.nick)}</span>
          <span class="lb-pts">${showScore ? `${e.score} pts` : '—'}</span>
        </div>`).join('')}
      ${myI>=10?`<div class="lb-row me"><span class="lb-rank">${myI+1}</span><span class="lb-nick">${esc(nick)}</span><span class="lb-pts">${showScore?`${lb[myI].score} pts`:'—'}</span></div>`:''}
    </div>
    <button class="btn btn-ghost w-full" style="margin-top:8px;font-size:12px;" onclick="showLeaderboard()">Classifica completa →</button>`;
}
function buildShareText(total, breakdown, roundName) {
  const emojis=(breakdown||[]).map(p=>{const pts=p.finalPts!=null?p.finalPts:(p.pts||0);return pts>0?'🟢':pts<0?'🔴':'🟡';}).join('');
  return `FantaPick WC26 — ${roundName}\n\n🌍 ${total} pts\n\n${emojis}\n\nfantapick.it`;
}
function copyShare() {
  const txt=buildShareText(S.resultData?.total||0,S.resultData?.breakdown||[],ROUND_NAMES[CURRENT_ROUND]);
  navigator.clipboard?.writeText(txt).then(()=>showToast('Copiato! 📋')).catch(()=>showToast('Copia manuale: tocca e tieni premuto.'));
}

/* ============================================================
   INIT
   ============================================================ */
function injectDevBadge() {
  const mk = (txt, bg, fg, side) => {
    const b = document.createElement('div');
    b.textContent = txt;
    b.style.cssText = `position:fixed;bottom:8px;${side}:8px;background:${bg};color:${fg};` +
      `font-size:10px;font-family:monospace;font-weight:700;padding:3px 7px;` +
      `border-radius:4px;z-index:9999;pointer-events:none;letter-spacing:1px;`;
    document.body.appendChild(b);
  };
  if (IS_LOCAL) mk('🟡 LOCAL', '#f0b429', '#000', 'left');
  if (DEV_MODE)  mk('🔴 DEV',  '#ef4444', '#fff', 'right');
}

async function init() {
  render(`<div class="screen" style="align-items:center;justify-content:center;" id="s-load">
    <div class="flex-col gap-12" style="align-items:center;">
      <div class="spinner"></div>
      <div class="subtitle">Caricamento dati…</div>
    </div>
  </div>`);
  try {
    await loadData();
    await loadSupabaseState();
    if (DEV_MODE || IS_LOCAL) injectDevBadge();

    // Nickname gate — must be set before any screen is shown
    if (!getNickname()) await showNicknameScreen();

    // Admin page routing
    if (new URLSearchParams(location.search).get('page') === 'admin') {
      if (isAdminAuthed()) showAdminPanel(); else showAdminLogin();
      return;
    }

    startPublicPolling();
    const saved = loadSavedDraft();
    if (saved && saved.round === CURRENT_ROUND && !DEV_MODE) {
      if (saved.phase === 'result') { showResult(true); return; }
      // Reject legacy state without pre-generated pools
      if (!saved.pools || !saved.pools.length) { clearDraftState(); showHome(); return; }
      if (saved.phase === 'swappick') {
        restoreDraftState(saved);
        const swapPool = S.swapPools.find(sp => sp.id === S.activeSwapPool);
        if (swapPool) {
          SWAP_CANDIDATES = swapPool.candidates;
          showSwapPickPlayer(swapPool.slot, S.swapTargetSlotIdx);
        } else {
          showFormationScreen();
        }
        return;
      }
      if (saved.phase === 'draft' || saved.phase === 'formation') {
        restoreDraftState(saved);
        if (saved.phase === 'draft' && S.selectedCT) { showPickPlayer(); return; }
        if (saved.phase === 'draft' && !S.selectedCT) { showPickCT(); return; }
        showFormationScreen(); return;
      }
    }
    showHome();
  }
  catch(e) {
    render(`<div class="screen" style="align-items:center;justify-content:center;">
      <div class="center">
        <div class="title" style="color:var(--bad);">Errore</div>
        <div class="subtitle" style="margin-top:8px;">Impossibile caricare i dati.<br><code style="font-size:11px;">${esc(String(e))}</code></div>
        <button class="btn btn-primary" style="margin-top:16px;" onclick="init()">Riprova</button>
      </div>
    </div>`);
  }
}
/* ============================================================
   DESKTOP UI
   ============================================================ */
function updateDesktopUI() {
  if (window.innerWidth < 1024) return;
  updateDesktopNav();
  updateDesktopSidebar();
}

function updateDesktopNav() {
  const nav = document.getElementById('d-nav');
  if (!nav) return;
  const rs = getRoundState();
  const rn = ROUND_NAMES[rs.currentRound] || rs.currentRound;
  const stCfg = {
    upcoming: { label:'⏳ Prossimamente', bg:'rgba(255,255,255,0.07)', color:'var(--muted)' },
    live:     { label:'🔴 Live',          bg:'var(--bad)',              color:'#fff'         },
    completed:{ label:'✅ Concluso',      bg:'rgba(34,197,94,0.15)',    color:'var(--good)'  },
  };
  const st  = stCfg[rs.roundState] || stCfg.upcoming;
  const nick   = getNickname();
  const allDR  = getAllDrafts()[rs.currentRound] || [];
  const myEntry = nick ? allDR.find(d => d.nick === nick) : null;
  const myRank  = myEntry ? allDR.indexOf(myEntry) + 1 : null;
  const showSc  = rs.roundState !== 'upcoming';

  nav.innerHTML = `
    <div style="font-family:var(--font-title);font-weight:900;font-size:17px;letter-spacing:2px;
                color:var(--muted);white-space:nowrap;flex:none;">
      FANTA<span style="color:var(--gold);">PICK</span>&nbsp;<span style="font-size:12px;font-weight:400;">WC26</span>
    </div>
    <div style="display:flex;align-items:center;gap:10px;flex:1;justify-content:center;">
      <span style="font-family:var(--font-title);font-size:14px;font-weight:700;color:var(--text);white-space:nowrap;">${esc(rn)}</span>
      <span style="font-family:var(--font-title);font-size:10px;font-weight:700;letter-spacing:0.5px;
                   padding:3px 10px;border-radius:99px;white-space:nowrap;
                   background:${st.bg};color:${st.color};">${st.label}</span>
    </div>
    <div style="font-family:var(--font-title);font-size:13px;white-space:nowrap;min-width:100px;text-align:right;flex:none;">
      ${myEntry && showSc
        ? `<span style="color:var(--gold);font-weight:700;">${myEntry.score} pts</span><span style="color:var(--muted);"> · #${myRank}</span>`
        : nick ? `<span style="color:var(--muted);">${esc(nick)}</span>` : ''}
    </div>`;
}

function updateDesktopSidebar() {
  const sidebarEl = document.getElementById('d-sidebar');
  if (!sidebarEl) return;
  const rs  = getRoundState();
  const rn  = ROUND_NAMES[rs.currentRound] || rs.currentRound;
  const allDR  = getAllDrafts()[rs.currentRound] || [];
  const showSc = rs.roundState !== 'upcoming';
  const nick   = getNickname();
  const lb = rs.roundState === 'upcoming'
    ? [...allDR].sort((a,b) => (a.ts||0)-(b.ts||0))
    : [...allDR];

  sidebarEl.innerHTML = `
    <div class="section-head" style="margin-bottom:12px;">${esc(rn)}</div>
    ${lb.length === 0 ? `<div class="subtitle">Nessun draft ancora.</div>` : `
      <div class="flex-col gap-8">
        ${lb.slice(0,10).map((e,i) => `
          <div style="display:flex;align-items:center;gap:6px;padding:7px 9px;
                      background:${e.nick===nick?'#1a0f00':'var(--panel)'};
                      border:1px solid ${e.nick===nick?'var(--gold)':'var(--border)'};
                      border-radius:8px;">
            <span style="font-family:var(--font-title);font-weight:900;font-size:13px;
                         color:${i<3?'var(--gold)':'var(--muted)'};min-width:18px;text-align:center;">${i+1}</span>
            <span style="flex:1;font-size:12px;font-weight:500;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">${esc(e.nick)}</span>
            <span style="font-family:var(--font-title);font-weight:700;font-size:12px;color:var(--gold);">${showSc?e.score:''}</span>
          </div>`).join('')}
      </div>`}`;
}

window.addEventListener('resize', () => { if (window.innerWidth >= 1024) updateDesktopUI(); });

/* ============================================================
   PUBLIC POLLING
   ============================================================ */
let _publicPollTimer = null;

function startPublicPolling() {
  stopPublicPolling();
  _publicPollTimer = setInterval(async () => {
    await refreshFromSupabase();
    if (_roundState.roundState === 'live' && document.getElementById('s-result')) {
      showResult(true);
    }
  }, 30000);
  document.addEventListener('visibilitychange', onVisibilityChange);
}

function stopPublicPolling() {
  if (_publicPollTimer) { clearInterval(_publicPollTimer); _publicPollTimer = null; }
  document.removeEventListener('visibilitychange', onVisibilityChange);
}

async function onVisibilityChange() {
  if (!document.hidden) {
    await refreshFromSupabase();
    if (document.getElementById('s-result')) showResult(true);
    if (document.getElementById('s-leaderboard') && _lbRoundState === 'live') {
      await _lbRefreshPage();
    }
  }
}

/* ============================================================
   ADMIN AUTH SCREENS
   ============================================================ */
function showAdminLogin() {
  render(`
    <div class="screen" style="justify-content:center;" id="s-admin-login">
      <div class="eyebrow" style="color:var(--bad);text-align:center;">AREA ADMIN</div>
      <div style="font-family:var(--font-title);font-size:32px;font-weight:700;text-align:center;margin:8px 0 24px;">Accesso Admin</div>
      <div class="subtitle" style="text-align:center;margin-bottom:24px;">Inserisci la password per continuare.</div>
      <input id="admin-pass-input" type="password" placeholder="Password"
        style="width:100%;padding:14px;background:var(--panel);border:1.5px solid var(--border);
               border-radius:var(--radius);color:var(--text);font-size:16px;font-family:var(--font-body);
               outline:none;text-align:center;"
        onkeydown="if(event.key==='Enter')submitAdminPassword()">
      <button class="btn btn-primary" style="margin-top:14px;" onclick="submitAdminPassword()">Accedi →</button>
      <button class="btn btn-ghost" style="margin-top:8px;" onclick="showHome()">← Torna alla home</button>
    </div>`);
  animIn('#s-admin-login');
  setTimeout(() => document.getElementById('admin-pass-input')?.focus(), 350);
}

function submitAdminPassword() {
  const val = (document.getElementById('admin-pass-input')?.value || '').trim();
  if (val === ADMIN_PASSWORD) {
    setAdminAuth();
    showAdminPanel();
  } else {
    showToast('Password errata!');
    const inp = document.getElementById('admin-pass-input');
    if (inp) { inp.value = ''; inp.focus(); }
  }
}

/* ============================================================
   ADMIN PANEL
   ============================================================ */
let _adminSaveTimer = null;

function showAdminPanel(tab) {
  tab = tab || 'matches';
  ensurePlayerPickerDrawer();
  const rs        = getRoundState();
  const roundName = ROUND_NAMES[rs.currentRound] || rs.currentRound;
  const stateLabel = { upcoming:'⏳ Upcoming', live:'🔴 Live', completed:'✅ Completed' }[rs.roundState] || rs.roundState;

  render(`
    <div class="screen" id="s-admin" style="padding:0;gap:0;height:100%;">
      <div style="padding:14px 18px 0;flex:none;">
        <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:2px;">
          <div>
            <div class="eyebrow" style="color:var(--bad);">AREA ADMIN</div>
            <div style="font-family:var(--font-title);font-size:20px;font-weight:700;line-height:1.1;">${esc(roundName)}</div>
            <div style="font-size:11px;color:var(--muted);margin-top:2px;">${stateLabel}</div>
          </div>
          <div style="display:flex;align-items:center;gap:10px;">
            <span id="admin-save-status" style="font-size:11px;color:var(--good);"></span>
            <button class="btn btn-ghost" style="font-size:11px;padding:6px 10px;" onclick="showHome()">Esci</button>
          </div>
        </div>
        <div style="display:flex;gap:0;border-bottom:1px solid var(--border);margin:10px -18px 0;padding:0 18px;">
          ${['matches','drafts','settings'].map(t => `
            <button onclick="showAdminPanel('${t}')"
              style="flex:1;padding:9px 4px;font-family:var(--font-title);font-size:11px;letter-spacing:1px;
                     font-weight:700;background:none;border:none;cursor:pointer;text-transform:uppercase;
                     color:${t===tab?'var(--gold)':'var(--muted)'};
                     border-bottom:2px solid ${t===tab?'var(--gold)':'transparent'};">
              ${t==='matches'?'Partite':t==='drafts'?'Draft':'Impostazioni'}
            </button>`).join('')}
        </div>
      </div>
      <div style="flex:1;overflow-y:auto;padding:14px 18px 40px;" id="admin-tab-content">
        ${tab==='matches' ? renderAdminMatchesTab() : tab==='drafts' ? renderAdminDraftsTab() : renderAdminSettingsTab()}
      </div>
    </div>`);
}

/* -------- Tab 1: Partite -------- */
function renderAdminMatchesTab() {
  const rs       = getRoundState();
  const fixtures = DATA.fixtures?.matches || [];
  const md       = getMatchData();
  const roundMd  = md[rs.currentRound] || {};

  if (!fixtures.length) return `<div class="subtitle center mt-20">Nessuna partita per questo round.</div>`;

  return fixtures.map(m => {
    const matchMd  = roundMd[m.id] || {};
    const hs       = matchMd.homeScore;
    const as_      = matchMd.awayScore;
    const completed = matchMd.completed || false;
    const live      = !completed && hs !== null && hs !== undefined;
    const icon      = completed ? '✅' : live ? '🔴' : '⏳';
    const dateStr   = m.date ? m.date.slice(5).replace('-','/') : '';
    const scoreStr  = (hs !== null && hs !== undefined) ? `${hs} - ${as_ !== null && as_ !== undefined ? as_ : '?'}` : '— - —';

    return `
      <div style="background:var(--panel);border:1px solid var(--border);border-radius:var(--radius-sm);margin-bottom:10px;">
        <div style="padding:12px 14px;display:flex;align-items:center;gap:8px;">
          <span style="font-size:15px;flex:none;">${icon}</span>
          <div style="flex:1;min-width:0;">
            <div style="font-family:var(--font-title);font-size:11px;color:var(--muted);">${dateStr}</div>
            <div style="font-family:var(--font-title);font-size:14px;font-weight:700;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;">
              ${esc(m.home)} vs ${esc(m.away)}
            </div>
          </div>
          <div style="text-align:right;flex:none;">
            <div style="font-family:var(--font-title);font-size:18px;font-weight:700;">${scoreStr}</div>
            <button class="btn btn-ghost" style="font-size:10px;padding:4px 10px;margin-top:4px;"
              onclick="toggleMatchEdit('${m.id}')">Modifica</button>
          </div>
        </div>
        <div id="edit-${m.id}" style="display:none;border-top:1px solid var(--border);padding:14px 14px 10px;"></div>
      </div>`;
  }).join('');
}

function toggleMatchEdit(matchId) {
  const el = document.getElementById(`edit-${matchId}`);
  if (!el) return;
  const isOpen = el.style.display !== 'none';
  if (isOpen) {
    el.style.display = 'none';
  } else {
    document.querySelectorAll('[id^="edit-r"]').forEach(e => { e.style.display = 'none'; });
    el.style.display = 'block';
    const rs      = getRoundState();
    const md      = getMatchData();
    const matchMd = (md[rs.currentRound] || {})[matchId] || {};
    const fixture = (DATA.fixtures?.matches || []).find(m => m.id === matchId);
    if (fixture) el.innerHTML = renderMatchEditPanel(fixture, matchMd);
  }
}

const EVENT_TYPES = [
  { type: 'goal',        label: '⚽ Gol'          },
  { type: 'assist',      label: '🅰️ Assist'        },
  { type: 'yellow_card', label: '🟨 Ammonizione'   },
  { type: 'red_card',    label: '🟥 Espulsione'    },
  { type: 'pen_scored',  label: '⚽ Rig. segnato'  },
  { type: 'pen_missed',  label: '❌ Rig. sbagliato' },
  { type: 'pen_saved',   label: '🥅 Rig. parato'   },
  { type: 'own_goal',    label: '💀 Autogol'       },
];

function renderMatchEditPanel(match, matchData) {
  const hs        = matchData.homeScore;
  const as_       = matchData.awayScore;
  const completed = matchData.completed || false;
  const mp        = matchData.players || {};
  const events    = mp.events  || [];
  const played    = mp.played; // null = all played

  const mid  = jsProp(match.id);

  const homeSq = DATA.squads.find(sq => sq.team === match.home);
  const awaySq = DATA.squads.find(sq => sq.team === match.away);
  const homePl = ([...(homeSq?.players || [])]).map(p => ({...p, team: match.home, flag: homeSq?.flag || ''}))
    .sort((a,b) => ({P:0,D:1,C:2,A:3}[a.role]||4) - ({P:0,D:1,C:2,A:3}[b.role]||4));
  const awayPl = ([...(awaySq?.players || [])]).map(p => ({...p, team: match.away, flag: awaySq?.flag || ''}))
    .sort((a,b) => ({P:0,D:1,C:2,A:3}[a.role]||4) - ({P:0,D:1,C:2,A:3}[b.role]||4));

  // score stepper
  const hsVal = hs !== null && hs !== undefined ? hs : 0;
  const asVal = as_ !== null && as_ !== undefined ? as_ : 0;
  const scoreHtml = `
    <div class="me-score-row">
      <div class="me-team-name">${esc(match.home)}</div>
      <div class="me-stepper">
        <button onclick="changeMatchScore('${mid}',-1,0)">−</button>
        <span id="me-hs-${mid}">${hs !== null && hs !== undefined ? hs : '—'}</span>
        <button onclick="changeMatchScore('${mid}',+1,0)">+</button>
      </div>
      <span class="me-dash">–</span>
      <div class="me-stepper">
        <button onclick="changeMatchScore('${mid}',-1,1)">−</button>
        <span id="me-as-${mid}">${as_ !== null && as_ !== undefined ? as_ : '—'}</span>
        <button onclick="changeMatchScore('${mid}',+1,1)">+</button>
      </div>
      <div class="me-team-name">${esc(match.away)}</div>
    </div>`;

  // status pills
  const statuses = [
    { v:'upcoming',  l:'⏳ In programma' },
    { v:'live',      l:'🔴 Live'         },
    { v:'completed', l:'✅ Completata'   },
  ];
  const curStatus = completed ? 'completed' : (hs !== null ? 'live' : 'upcoming');
  const statusHtml = `
    <div class="me-pills">
      ${statuses.map(s => `
        <button class="me-pill${s.v===curStatus?' active':''}" onclick="setMatchStatus('${mid}','${s.v}')">
          ${s.l}
        </button>`).join('')}
    </div>`;

  // presenze accordion for a team
  function presenzaBlock(teamPlayers, teamName) {
    const pKeys = teamPlayers.map(p => playerKey(p));
    return `
      <details class="me-presenze">
        <summary>👥 Presenze ${esc(teamName)}</summary>
        <div class="me-presenze-list">
          ${teamPlayers.map(p => {
            const pk = playerKey(p);
            const isPlayed = !Array.isArray(played) || played.includes(pk);
            return `
              <label class="me-pres-row">
                <input type="checkbox" ${isPlayed?'checked':''}
                  onchange="togglePlayerPresence('${mid}','${jsProp(pk)}',this.checked)">
                <span class="role-badge ${roleClass(p.role)}" style="font-size:9px;">${roleName(p.role)}</span>
                <span style="font-size:12px;">${esc(p.name)}</span>
              </label>`;
          }).join('')}
        </div>
      </details>`;
  }

  // event buttons for a team
  function eventBtns(team) {
    return `
      <div class="me-event-grid">
        ${EVENT_TYPES.map(et => `
          <button class="me-evt-btn" onclick="openPlayerPicker('${mid}','${jsProp(team)}','${et.type}')">
            ${et.label}
          </button>`).join('')}
      </div>`;
  }

  // two-column teams panel
  const teamsHtml = `
    <div class="me-teams">
      <div class="me-team-col">
        <div class="me-team-header">${esc(match.home)}</div>
        ${presenzaBlock(homePl, match.home)}
        ${eventBtns(match.home)}
      </div>
      <div class="me-team-col">
        <div class="me-team-header">${esc(match.away)}</div>
        ${presenzaBlock(awayPl, match.away)}
        ${eventBtns(match.away)}
      </div>
    </div>`;

  // event log
  const logHtml = `
    <div class="me-log-head">Log eventi (${events.length})</div>
    ${events.length === 0
      ? `<div style="font-size:12px;color:var(--muted);padding:6px 0;">Nessun evento registrato.</div>`
      : events.map((e, idx) => {
          const et = EVENT_TYPES.find(x => x.type === e.type);
          return `
            <div class="me-log-row">
              <span class="me-log-min">${e.minute != null ? e.minute+"'" : '—'}</span>
              <span class="me-log-icon">${et ? et.label.split(' ')[0] : '?'}</span>
              <span class="me-log-name">${esc(e.playerName)}</span>
              <span class="me-log-team">(${esc(e.team)})</span>
              <button class="me-log-del" onclick="deleteMatchEvent('${mid}',${idx})">✕</button>
            </div>`;
        }).join('')}`;

  return `${scoreHtml}${statusHtml}${teamsHtml}
    <div style="border-top:1px solid var(--border);margin-top:14px;padding-top:12px;">${logHtml}</div>`;
}

function saveMatchField(matchId, field, value) {
  const round = getRoundState().currentRound;
  _matchData[round] = _matchData[round] || {};
  _matchData[round][matchId] = _matchData[round][matchId] || { homeScore: null, awayScore: null, completed: false, players: {} };
  _matchData[round][matchId][field] = value;
  scheduleAdminRecalc();
}

function _ensureMatch(round, matchId) {
  _matchData[round] = _matchData[round] || {};
  _matchData[round][matchId] = _matchData[round][matchId] ||
    { homeScore: null, awayScore: null, completed: false, players: {} };
  _matchData[round][matchId].players = _matchData[round][matchId].players || {};
  return _matchData[round][matchId];
}

function refreshMatchPanel(matchId) {
  const el = document.getElementById(`edit-${matchId}`);
  if (!el) return;
  const rs      = getRoundState();
  const matchMd = (_matchData[rs.currentRound] || {})[matchId] || {};
  const fixture = (DATA.fixtures?.matches || []).find(m => m.id === matchId);
  if (fixture) el.innerHTML = renderMatchEditPanel(fixture, matchMd);
}

function changeMatchScore(matchId, delta, side) {
  const round = getRoundState().currentRound;
  const md = _ensureMatch(round, matchId);
  const field = side === 0 ? 'homeScore' : 'awayScore';
  const cur = md[field] !== null && md[field] !== undefined ? md[field] : 0;
  md[field] = Math.max(0, cur + delta);
  refreshMatchPanel(matchId);
  scheduleAdminRecalc();
}

function setMatchStatus(matchId, status) {
  const round = getRoundState().currentRound;
  const md = _ensureMatch(round, matchId);
  md.completed = (status === 'completed');
  if (status !== 'upcoming' && md.homeScore === null) md.homeScore = 0;
  if (status !== 'upcoming' && md.awayScore === null) md.awayScore = 0;
  refreshMatchPanel(matchId);
  scheduleAdminRecalc();
}

function togglePlayerPresence(matchId, pKey, present) {
  const round = getRoundState().currentRound;
  const md = _ensureMatch(round, matchId);
  const fixture = (DATA.fixtures?.matches || []).find(m => m.id === matchId);
  if (!fixture) return;

  // Build full played list if not yet set (first interaction)
  if (!Array.isArray(md.players.played)) {
    const homeSq = DATA.squads.find(sq => sq.team === fixture.home);
    const awaySq = DATA.squads.find(sq => sq.team === fixture.away);
    md.players.played = [
      ...(homeSq?.players || []).map(p => playerKey({...p, team: fixture.home})),
      ...(awaySq?.players || []).map(p => playerKey({...p, team: fixture.away})),
    ];
  }
  if (present) {
    if (!md.players.played.includes(pKey)) md.players.played.push(pKey);
  } else {
    md.players.played = md.players.played.filter(k => k !== pKey);
  }
  scheduleAdminRecalc();
}

function addMatchEvent(matchId, event) {
  const round = getRoundState().currentRound;
  const md = _ensureMatch(round, matchId);
  md.players.events = md.players.events || [];
  md.players.events.push({ id: Math.random().toString(36).slice(2), ...event });
  refreshMatchPanel(matchId);
  scheduleAdminRecalc();
}

function deleteMatchEvent(matchId, idx) {
  const round = getRoundState().currentRound;
  const md = (_matchData[round] || {})[matchId];
  if (!md) return;
  md.players.events = (md.players.events || []).filter((_, i) => i !== idx);
  refreshMatchPanel(matchId);
  scheduleAdminRecalc();
}

/* ---------- Player Picker Drawer ---------- */
function ensurePlayerPickerDrawer() {
  if (document.getElementById('player-picker-drawer')) return;
  const el = document.createElement('div');
  el.id = 'player-picker-drawer';
  el.innerHTML = '<div id="player-picker-inner"></div>';
  el.onclick = e => { if (e.target === el) closePlayerPicker(); };
  document.body.appendChild(el);
}

function openPlayerPicker(matchId, team, eventType) {
  _pickerCtx = { matchId, team, eventType };
  const sq = DATA.squads.find(s => s.team === team);
  const players = ([...(sq?.players || [])])
    .sort((a,b) => ({P:0,D:1,C:2,A:3}[a.role]||4) - ({P:0,D:1,C:2,A:3}[b.role]||4));
  const et = EVENT_TYPES.find(x => x.type === eventType);
  const inner = document.getElementById('player-picker-inner');
  if (!inner) return;
  inner.innerHTML = `
    <div class="picker-header">
      <span style="font-family:var(--font-title);font-size:14px;font-weight:700;">${et?.label || eventType} — ${esc(team)}</span>
      <button class="picker-close" onclick="closePlayerPicker()">✕</button>
    </div>
    <div class="picker-list">
      ${players.map(p => `
        <div class="picker-row" onclick="confirmPickerPlayer('${jsProp(playerKey({...p,team}))}','${jsProp(p.name)}','${jsProp(team)}')">
          <span class="role-badge ${roleClass(p.role)}" style="font-size:10px;">${roleName(p.role)}</span>
          <span class="picker-name">${esc(p.name)}</span>
        </div>`).join('')}
    </div>`;
  document.getElementById('player-picker-drawer').classList.add('open');
}

function closePlayerPicker() {
  document.getElementById('player-picker-drawer')?.classList.remove('open');
  _pickerCtx = null;
}

function confirmPickerPlayer(pKey, playerName, team) {
  if (!_pickerCtx) return;
  const { matchId, eventType } = _pickerCtx;
  closePlayerPicker();
  addMatchEvent(matchId, { type: eventType, playerKey: pKey, playerName, team, minute: null });
}

function scheduleAdminRecalc() {
  updateSaveIndicator('saving');
  clearTimeout(_adminSaveTimer);
  _adminSaveTimer = setTimeout(async () => {
    const round = getRoundState().currentRound;
    await saveMatchDataToSupabase(round);
    await recalculateAllScores(round);
    updateSaveIndicator('saved');
  }, 500);
}

function updateSaveIndicator(state) {
  const el = document.getElementById('admin-save-status');
  if (!el) return;
  el.textContent = state === 'saving' ? 'Salvando...' : 'Salvato ✓';
  el.style.color  = state === 'saving' ? 'var(--muted)' : 'var(--good)';
}

/* -------- Tab 2: Draft registrati -------- */
function renderAdminDraftsTab() {
  const rs    = getRoundState();
  const round = rs.currentRound;
  const allDraftsRound = getAllDrafts()[round] || [];
  const roundName = ROUND_NAMES[round];
  const showScore = rs.roundState !== 'upcoming';

  if (!allDraftsRound.length) {
    return `<div class="subtitle" style="text-align:center;margin-top:40px;">Nessun draft registrato per i ${esc(roundName)}.</div>`;
  }

  return `
    <div style="font-size:12px;color:var(--muted);margin-bottom:12px;">${allDraftsRound.length} draft registrati per i ${esc(roundName)}</div>
    <div class="flex-col gap-8">
      ${allDraftsRound.map((d,i) => {
        const capName = (d.breakdown||[]).find(p => playerKey(p) === d.captainKey)?.name || '—';
        return `
          <div style="background:var(--panel);border:1px solid var(--border);border-radius:var(--radius-sm);padding:12px 14px;">
            <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
              <span class="lb-rank ${i<3?'top3':''}">${i+1}</span>
              <span style="font-family:var(--font-title);font-size:14px;font-weight:700;flex:1;">${esc(d.nick)}</span>
              <span style="font-family:var(--font-title);font-size:16px;color:var(--gold);font-weight:700;">
                ${showScore ? `${d.score} pts` : '—'}
              </span>
            </div>
            <div style="font-size:11px;color:var(--muted);">
              CT: ${esc(d.ct?.name||'—')} · ${esc(d.formation||'—')} · Cap: ${esc(capName)}
              ${d.ctBonusApplied ? ' · <span style="color:var(--good);">×1.25✓</span>' : ''}
            </div>
            <div style="margin-top:6px;">
              <button class="btn btn-ghost" style="font-size:10px;padding:4px 10px;" onclick="toggleDraftDetail('dd-${i}')">Dettaglio ▾</button>
            </div>
            <div id="dd-${i}" style="display:none;margin-top:8px;">
              ${(d.breakdown||[]).map(p=>breakdownRowHtml(p)).join('')}
            </div>
          </div>`;
      }).join('')}
    </div>`;
}

function toggleDraftDetail(id) {
  const el = document.getElementById(id);
  if (!el) return;
  el.style.display = el.style.display === 'none' ? 'block' : 'none';
}

/* -------- Tab 3: Impostazioni -------- */
function renderAdminSettingsTab() {
  const rs = getRoundState();
  return `
    <div class="flex-col gap-16">
      <div>
        <div class="section-head">Round corrente</div>
        <select onchange="updateRoundSetting('currentRound',this.value)"
          style="width:100%;padding:12px;background:var(--panel);border:1px solid var(--border);
                 border-radius:var(--radius-sm);color:var(--text);font-size:14px;">
          ${Object.entries(ROUND_NAMES).map(([k,v]) =>
            `<option value="${k}" ${rs.currentRound===k?'selected':''}>${esc(v)}</option>`).join('')}
        </select>
      </div>
      <div>
        <div class="section-head">Stato round</div>
        <select onchange="updateRoundSetting('roundState',this.value)"
          style="width:100%;padding:12px;background:var(--panel);border:1px solid var(--border);
                 border-radius:var(--radius-sm);color:var(--text);font-size:14px;">
          <option value="upcoming" ${rs.roundState==='upcoming'?'selected':''}>⏳ upcoming — partite non ancora iniziate</option>
          <option value="live"     ${rs.roundState==='live'?'selected':''}>🔴 live — round in corso</option>
          <option value="completed"${rs.roundState==='completed'?'selected':''}>✅ completed — round concluso</option>
        </select>
        <div style="font-size:11px;color:var(--muted);margin-top:6px;">
          Passare a "completed" ricalcola tutti i punteggi e sblocca il Perfect XI.
        </div>
      </div>
      <div>
        <div class="section-head">Nazionali qualificate (round successivo)</div>
        <div style="font-size:11px;color:var(--muted);margin-bottom:8px;">
          Inserisci i codici team separati da virgola — sblocca il draft per il round selezionato.
        </div>
        <select id="qt-round-select"
          style="width:100%;padding:10px;background:var(--panel);border:1px solid var(--border);
                 border-radius:var(--radius-sm);color:var(--text);font-size:13px;margin-bottom:8px;">
          ${Object.entries(ROUND_NAMES).map(([k,v]) =>
            `<option value="${k}">${esc(v)}</option>`).join('')}
        </select>
        <textarea id="qt-input" placeholder="Es: BRA,ARG,FRA,ESP,ITA,GER"
          style="width:100%;padding:10px;background:var(--panel);border:1px solid var(--border);
                 border-radius:var(--radius-sm);color:var(--text);font-size:13px;
                 font-family:var(--font-body);resize:vertical;min-height:64px;"></textarea>
        <button class="btn btn-ghost" style="width:100%;margin-top:8px;"
          onclick="saveQualifiedTeamsForNextRound()">Salva e sblocca round →</button>
      </div>
      <div>
        <div class="section-head">Azioni</div>
        <button class="btn btn-ghost" style="width:100%;margin-bottom:8px;"
          onclick="adminForceRecalc()">↻ Ricalcola punteggi ora</button>
        ${DEV_MODE ? `
          <div style="border:1px solid var(--bad);border-radius:var(--radius-sm);padding:14px;margin-top:8px;">
            <div class="section-head" style="color:var(--bad);margin-bottom:6px;">DEV — Reset round</div>
            <div class="subtitle" style="margin-bottom:10px;">Cancella tutti i draft del round corrente.</div>
            <button class="btn btn-ghost" style="border-color:var(--bad);color:var(--bad);width:100%;"
              onclick="resetRoundDrafts()">Reset Draft ⚠️</button>
          </div>` : ''}
    </div>`;
}

async function updateRoundSetting(field, value) {
  if (field === 'currentRound') {
    _roundState.currentRound = value;
    await loadRoundDataFromSupabase(value);
  } else {
    _roundState.roundState = value;
    await setRoundState(_roundState);
    if (value === 'completed') await recalculateAllScores(_roundState.currentRound);
  }
  showAdminPanel('settings');
  showToast(`${field}: ${value}`);
}

async function adminForceRecalc() {
  const round = getRoundState().currentRound;
  await recalculateAllScores(round);
  showToast('Punteggi ricalcolati!');
  updateSaveIndicator('saved');
}

async function resetRoundDrafts() {
  if (!DEV_MODE) return;
  if (!confirm('Cancella tutti i draft del round corrente?')) return;
  if (!confirm('Conferma: azione irreversibile.')) return;
  const round = getRoundState().currentRound;
  _allDrafts[round] = [];
  const { error } = await sb.from('drafts').delete().eq('round', round);
  if (error) console.error('resetRoundDrafts:', error);
  const s = loadStorage();
  if (s.drafts) delete s.drafts[round];
  saveStorage(s);
  showToast('Draft resettati!');
  showAdminPanel('settings');
}

/* ============================================================
   LEADERBOARD SCREEN
   ============================================================ */
const LB_PAGE_SIZE = 20;

let _lbRound       = null;
let _lbPage        = 0;
let _lbEntries     = [];
let _lbTotal       = 0;
let _lbRoundState  = 'upcoming';
let _lbProgress    = { completed: 0, total: 0 };
let _lbAvailRounds = [];   // [{ id, label_it, order_num, state }]
let _lbCumulative  = null; // null | [{ nickname, total, breakdown }]
let _lbPollTimer   = null;

async function showLeaderboard(round) {
  render(`<div class="screen" style="align-items:center;justify-content:center;" id="s-lb-load">
    <div class="flex-col gap-12" style="align-items:center;">
      <div class="spinner"></div>
      <div class="subtitle">Caricamento classifica…</div>
    </div>
  </div>`);
  stopLbPolling();

  try {
    _lbAvailRounds = await _lbLoadAvailableRounds();
    _lbRound = round
      || _lbAvailRounds.find(r => r.id === CURRENT_ROUND)?.id
      || _lbAvailRounds[0]?.id
      || CURRENT_ROUND;
    _lbPage    = 0;
    _lbEntries = [];
    await _lbFetchPage(0);

    const completedIds = _lbAvailRounds.filter(r => r.state === 'completed').map(r => r.id);
    _lbCumulative = await _lbLoadCumulative(completedIds);

    _renderLeaderboard();
    if (_lbRoundState === 'live') startLbPolling();
  } catch(e) {
    console.error('showLeaderboard:', e);
    render(`<div class="screen" style="align-items:center;justify-content:center;">
      <div class="center">
        <div class="subtitle" style="color:var(--bad);">Errore nel caricamento.</div>
        <button class="btn btn-ghost" style="margin-top:16px;" onclick="showHome()">← Home</button>
      </div>
    </div>`);
  }
}

async function _lbFetchPage(page) {
  const from = page * LB_PAGE_SIZE;
  const to   = from + LB_PAGE_SIZE - 1;
  const [
    { data: entries, count },
    { data: rsRow },
    { data: mpRows },
  ] = await Promise.all([
    sb.from('drafts')
      .select('nickname,score,formation,captain,created_at', { count: 'exact' })
      .eq('round', _lbRound)
      .order('score', { ascending: false })
      .order('created_at', { ascending: true })
      .range(from, to),
    sb.from('round_state').select('state').eq('round', _lbRound).single(),
    sb.from('match_data').select('completed').eq('round', _lbRound),
  ]);
  if (page === 0) _lbEntries = [];
  _lbEntries    = [..._lbEntries, ...(entries || [])];
  _lbTotal      = count || 0;
  _lbRoundState = rsRow?.state || 'upcoming';
  _lbProgress   = {
    completed: (mpRows || []).filter(m => m.completed).length,
    total:     (mpRows || []).length,
  };
}

async function _lbLoadAvailableRounds() {
  const [{ data: withDrafts }, { data: stateRows }, { data: meta }] = await Promise.all([
    sb.from('drafts').select('round'),
    sb.from('round_state').select('round,state'),
    sb.from('rounds').select('id,label_it,order_num').order('order_num'),
  ]);
  const stateMap = Object.fromEntries((stateRows || []).map(r => [r.round, r.state]));
  const draftSet = new Set((withDrafts || []).map(r => r.round));
  return (meta || [])
    .filter(r => draftSet.has(r.id) || (stateMap[r.id] && stateMap[r.id] !== 'upcoming'))
    .map(r => ({ ...r, state: stateMap[r.id] || 'upcoming' }));
}

async function _lbLoadCumulative(completedIds) {
  if (completedIds.length < 2) return null;
  const { data } = await sb.from('drafts')
    .select('nickname,round,score')
    .in('round', completedIds);
  if (!data) return null;
  const map = {};
  for (const { nickname, round, score } of data) {
    if (!map[nickname]) map[nickname] = { total: 0, breakdown: {} };
    map[nickname].total           += score || 0;
    map[nickname].breakdown[round] = score || 0;
  }
  return Object.entries(map)
    .map(([nickname, d]) => ({ nickname, ...d }))
    .sort((a, b) => b.total - a.total);
}

function _renderLeaderboard() {
  const nick    = getNickname();
  const rs      = _lbRoundState;
  const showPts = rs !== 'upcoming';

  // -- Tabs --
  const tabsHtml = _lbAvailRounds.length > 1 ? `
    <div style="display:flex;gap:0;border-bottom:1px solid var(--border);margin:0 -18px 14px;
                padding:0 18px;overflow-x:auto;-webkit-overflow-scrolling:touch;scrollbar-width:none;">
      ${_lbAvailRounds.map(r => `
        <button onclick="switchLbRound('${r.id}')"
          style="flex:none;padding:8px 14px;font-family:var(--font-title);font-size:11px;letter-spacing:1px;
                 font-weight:700;background:none;border:none;cursor:pointer;text-transform:uppercase;
                 white-space:nowrap;
                 color:${r.id===_lbRound?'var(--gold)':'var(--muted)'};
                 border-bottom:2px solid ${r.id===_lbRound?'var(--gold)':'transparent'};">
          ${esc(r.label_it)}
        </button>`).join('')}
    </div>` : '';

  // -- State badge + match progress --
  const badgeCfg = {
    upcoming:  { label: '⏳ In programma', bg: 'rgba(255,255,255,0.07)', color: 'var(--muted)' },
    live:      { label: '🔴 Live',         bg: 'var(--bad)',             color: '#fff'         },
    completed: { label: '✅ Completata',   bg: 'rgba(34,197,94,0.15)',   color: 'var(--good)'  },
  };
  const bc = badgeCfg[rs] || badgeCfg.upcoming;
  const progressHtml = rs === 'live' && _lbProgress.total > 0
    ? `<div style="font-size:11px;color:var(--muted);margin-top:4px;margin-bottom:10px;">
         ${_lbProgress.completed} / ${_lbProgress.total} partite completate
       </div>`
    : '<div style="margin-bottom:12px;"></div>';

  // -- Cumulative section --
  let cumulativeHtml = '';
  if (_lbCumulative && _lbCumulative.length > 0) {
    const names = _lbAvailRounds.filter(r => r.state === 'completed').map(r => r.label_it).join(', ');
    cumulativeHtml = `
      <details style="margin-bottom:16px;background:var(--panel);border:1px solid var(--border);border-radius:var(--radius-sm);">
        <summary style="padding:12px 14px;cursor:pointer;display:flex;align-items:center;justify-content:space-between;
                        font-family:var(--font-title);font-size:11px;font-weight:700;letter-spacing:1px;
                        text-transform:uppercase;color:var(--gold);list-style:none;user-select:none;">
          <span>Classifica cumulativa</span>
          <span style="font-weight:400;color:var(--muted);font-size:10px;text-transform:none;letter-spacing:0;">${esc(names)}</span>
        </summary>
        <div style="padding:0 14px 12px;">
          ${_lbCumulative.slice(0, 10).map((e, i) => {
            const isMe  = e.nickname === nick;
            const medal = i===0?'🥇':i===1?'🥈':i===2?'🥉'
              :`<span style="font-family:var(--font-title);font-weight:900;font-size:12px;color:var(--muted);">${i+1}</span>`;
            return `
              <div style="display:flex;align-items:center;gap:8px;padding:7px 0;
                          border-bottom:1px solid rgba(26,58,106,0.4);">
                <span style="width:22px;text-align:center;flex:none;">${medal}</span>
                <span style="flex:1;font-size:12px;font-weight:600;overflow:hidden;text-overflow:ellipsis;
                             white-space:nowrap;${isMe?'color:var(--gold);':''}">${esc(e.nickname)}</span>
                <span style="font-family:var(--font-title);font-weight:700;font-size:14px;color:var(--gold);flex:none;">
                  ${e.total.toFixed(1)}
                </span>
              </div>`;
          }).join('')}
        </div>
      </details>`;
  }

  // -- Upcoming placeholder --
  const upcomingPlaceholder = rs === 'upcoming' ? `
    <div style="background:var(--panel);border:1px solid var(--border);border-radius:var(--radius-sm);
                padding:24px;text-align:center;margin-bottom:16px;">
      <div style="font-size:28px;margin-bottom:8px;">⏳</div>
      <div style="font-size:13px;color:var(--muted);">Le partite non sono ancora iniziate.<br>La classifica si aggiornerà in tempo reale.</div>
    </div>` : '';

  // -- Entries --
  const entriesHtml = _lbEntries.length === 0 && rs !== 'upcoming'
    ? `<div class="subtitle center" style="margin:24px 0;">Nessun draft per questo round.</div>`
    : `<div class="flex-col gap-6">
        ${_lbEntries.map((e, i) => {
          const rank    = i + 1;
          const isMe    = e.nickname === nick;
          const medal   = rank===1?'🥇':rank===2?'🥈':rank===3?'🥉'
            :`<span style="font-family:var(--font-title);font-weight:900;font-size:13px;
                           color:${rank<=10?'var(--text)':'var(--muted)'};">${rank}</span>`;
          const captName = e.captain ? e.captain.split('|')[0] : '—';
          const fmt      = typeof e.formation === 'string' ? e.formation : '—';
          return `
            <div style="display:flex;align-items:center;gap:8px;padding:10px 12px;
                        background:${isMe?'rgba(240,180,41,0.08)':'var(--panel)'};
                        border:1px solid ${isMe?'var(--gold)':'var(--border)'};
                        border-radius:var(--radius-sm);">
              <span style="width:26px;text-align:center;flex:none;">${medal}</span>
              <div style="flex:1;min-width:0;">
                <div style="font-size:13px;font-weight:600;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">
                  ${esc(e.nickname)}${isMe?'&thinsp;<span style="font-size:9px;color:var(--gold);font-family:var(--font-title);font-weight:700;letter-spacing:0.5px;">TU</span>':''}
                </div>
                <div style="font-size:10px;color:var(--muted);margin-top:1px;">${esc(fmt)} · cap: ${esc(captName)}</div>
              </div>
              <span style="font-family:var(--font-title);font-size:16px;font-weight:700;
                           color:${showPts?'var(--gold)':'var(--muted)'};flex:none;min-width:40px;text-align:right;">
                ${showPts ? (e.score ?? 0) : '—'}
              </span>
            </div>`;
        }).join('')}
      </div>`;

  // -- Load more footer --
  const loaded  = _lbEntries.length;
  const hasMore = _lbTotal > loaded;
  const footerHtml = `
    <div style="margin-top:12px;text-align:center;">
      ${hasMore
        ? `<button class="btn btn-ghost w-full" onclick="lbLoadMore()">
             Carica altri (${_lbTotal - loaded} rimanenti)
           </button>`
        : ''}
      <div style="font-size:11px;color:var(--muted);margin-top:8px;">${_lbTotal} draft totali</div>
    </div>`;

  render(`
    <div class="screen" id="s-leaderboard" style="padding-bottom:40px;">
      <div style="display:flex;align-items:center;gap:12px;margin-bottom:6px;flex:none;">
        <button onclick="showHome()"
          style="background:none;border:none;color:var(--muted);font-size:22px;
                 cursor:pointer;padding:4px;line-height:1;flex:none;">←</button>
        <div style="flex:1;min-width:0;">
          <div class="eyebrow">Mondiale 2026</div>
          <div style="font-family:var(--font-title);font-size:24px;font-weight:900;line-height:1.1;">Classifica</div>
        </div>
        ${rs === 'live'
          ? `<button onclick="lbRefresh()"
               style="background:none;border:1px solid var(--border);border-radius:var(--radius-sm);
                      color:var(--muted);font-size:11px;padding:6px 10px;cursor:pointer;white-space:nowrap;flex:none;">
               ↻ Aggiorna
             </button>`
          : ''}
      </div>
      ${tabsHtml}
      <div style="display:flex;align-items:center;gap:8px;margin-bottom:0;">
        <span style="font-family:var(--font-title);font-size:10px;font-weight:700;letter-spacing:0.5px;
                     padding:3px 10px;border-radius:99px;background:${bc.bg};color:${bc.color};">${bc.label}</span>
      </div>
      ${progressHtml}
      ${cumulativeHtml}
      ${upcomingPlaceholder}
      ${entriesHtml}
      ${footerHtml}
      <button class="btn btn-ghost w-full" style="margin-top:24px;" onclick="showHome()">← Torna alla home</button>
    </div>`);
  animIn('#s-leaderboard');
}

async function switchLbRound(round) {
  if (round === _lbRound) return;
  stopLbPolling();
  _lbRound   = round;
  _lbPage    = 0;
  _lbEntries = [];
  await _lbFetchPage(0);
  _renderLeaderboard();
  if (_lbRoundState === 'live') startLbPolling();
}

async function lbLoadMore() {
  _lbPage++;
  await _lbFetchPage(_lbPage);
  _renderLeaderboard();
}

async function lbRefresh() {
  _lbPage    = 0;
  _lbEntries = [];
  await _lbFetchPage(0);
  _renderLeaderboard();
}

async function _lbRefreshPage() {
  await _lbFetchPage(0);
  _lbPage    = 0;
  _lbEntries = _lbEntries.slice(0, LB_PAGE_SIZE);
  _renderLeaderboard();
}

function startLbPolling() {
  stopLbPolling();
  _lbPollTimer = setInterval(async () => {
    if (!document.getElementById('s-leaderboard')) { stopLbPolling(); return; }
    await _lbRefreshPage();
    if (_lbRoundState === 'completed') stopLbPolling();
  }, 60000);
}

function stopLbPolling() {
  if (_lbPollTimer) { clearInterval(_lbPollTimer); _lbPollTimer = null; }
}

/* ============================================================
   SUPABASE HELPERS
   ============================================================ */

/** Load all state for a given round from Supabase into cache */
async function loadRoundDataFromSupabase(round) {
  // match_data
  const { data: mdRows } = await sb.from('match_data').select('*').eq('round', round);
  _matchData[round] = {};
  for (const m of (mdRows || [])) {
    _matchData[round][m.match_id] = {
      homeScore: m.home_score,
      awayScore: m.away_score,
      completed: m.completed,
      players:   m.player_stats || {},
    };
  }
  // drafts
  const { data: draftRows } = await sb.from('drafts').select('*')
    .eq('round', round).order('score', { ascending: false });
  _allDrafts[round] = (draftRows || []).map(draftFromRow);
}

/** Load everything needed on app start */
async function loadSupabaseState() {
  // Round state for current round
  const { data: rs } = await sb.from('round_state').select('*').eq('round', CURRENT_ROUND).single();
  if (rs) _roundState = { currentRound: CURRENT_ROUND, roundState: rs.state };

  await loadRoundDataFromSupabase(CURRENT_ROUND);

  // Qualified teams for current round
  const { data: qt } = await sb.from('qualified_teams').select('team_code').eq('round', CURRENT_ROUND);
  _qualifiedTeams = (qt || []).map(r => r.team_code);
}

/** Refresh round-state + drafts from Supabase (called by polling and visibilitychange) */
async function refreshFromSupabase() {
  try {
    const { data: rs } = await sb.from('round_state').select('*').eq('round', CURRENT_ROUND).single();
    if (rs) _roundState = { currentRound: _roundState.currentRound, roundState: rs.state };

    const { data: draftRows } = await sb.from('drafts').select('*')
      .eq('round', CURRENT_ROUND).order('score', { ascending: false });
    _allDrafts[CURRENT_ROUND] = (draftRows || []).map(draftFromRow);

    updateDesktopUI();
  } catch (e) { console.warn('refreshFromSupabase:', e); }
}

/** Write local _matchData[round] to Supabase (called after debounce) */
async function saveMatchDataToSupabase(round) {
  const roundMd = _matchData[round] || {};
  for (const [matchId, md] of Object.entries(roundMd)) {
    const fixture = (DATA.fixtures?.matches || []).find(m => m.id === matchId);
    const { error } = await sb.from('match_data').upsert({
      round,
      match_id:    matchId,
      home_team:   fixture?.home  || '',
      away_team:   fixture?.away  || '',
      home_score:  md.homeScore   ?? null,
      away_score:  md.awayScore   ?? null,
      completed:   md.completed   || false,
      player_stats: md.players    || {},
    }, { onConflict: 'round,match_id' });
    if (error) console.error('saveMatchData upsert:', error);
  }
}

/** Submit a completed draft to Supabase; retry on reconnect if offline */
async function submitDraftToSupabase(round, entry) {
  try {
    const { error } = await sb.from('drafts')
      .upsert(draftToRow(round, entry), { onConflict: 'round,nickname' });
    if (error) throw error;
    localStorage.removeItem('fantapick_pending_draft');
  } catch (e) {
    console.warn('submitDraftToSupabase failed, queuing:', e);
    try { localStorage.setItem('fantapick_pending_draft', JSON.stringify({ round, entry })); } catch {}
    showOfflineBanner();
  }
}

/** Admin: save qualified teams for a given round */
async function saveQualifiedTeamsForNextRound() {
  const roundSel  = document.getElementById('qt-round-select')?.value;
  const rawInput  = document.getElementById('qt-input')?.value || '';
  const teamCodes = rawInput.split(',').map(s => s.trim().toUpperCase()).filter(Boolean);
  if (!roundSel || !teamCodes.length) { showToast('Seleziona round e inserisci le nazionali!'); return; }

  await sb.from('qualified_teams').delete().eq('round', roundSel);
  if (teamCodes.length) {
    const { error } = await sb.from('qualified_teams')
      .insert(teamCodes.map(code => ({ round: roundSel, team_code: code })));
    if (error) { showToast('Errore nel salvataggio!'); console.error(error); return; }
  }
  showToast(`✓ ${teamCodes.length} nazionali salvate per ${ROUND_NAMES[roundSel] || roundSel}`);
}

/* -------- Offline banner -------- */
function showOfflineBanner() {
  if (document.getElementById('offline-banner')) return;
  const el = document.createElement('div');
  el.id = 'offline-banner';
  el.style.cssText = 'position:fixed;bottom:0;left:0;right:0;background:rgba(239,68,68,0.92);color:#fff;' +
    'font-size:12px;text-align:center;padding:10px 16px;z-index:9999;font-family:var(--font-body);';
  el.textContent = 'Connessione assente — il draft verrà salvato al ripristino della connessione.';
  document.body.appendChild(el);
}
function hideOfflineBanner() { document.getElementById('offline-banner')?.remove(); }

window.addEventListener('online', async () => {
  hideOfflineBanner();
  const pending = localStorage.getItem('fantapick_pending_draft');
  if (pending) {
    try {
      const { round, entry } = JSON.parse(pending);
      await submitDraftToSupabase(round, entry);
    } catch {}
  }
});

document.addEventListener('DOMContentLoaded', init);
