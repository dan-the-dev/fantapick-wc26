# FantaPick WC26

A standalone browser-based fantasy football game built for **FIFA World Cup 2026**. No backend, no build step, no accounts — just open the page and play.

---

## What is it?

FantaPick is a pick-em fantasy game where each player drafts an 11-man squad from the real WC2026 squads, choosing a formation, a captain, and a "CT" (Club Tecnico) formation bonus. Points are calculated from real match events entered by the admin. A live leaderboard ranks all participants.

The game is designed to be hosted statically (Netlify, GitHub Pages, any file server) and shared via link. All state lives in the browser's `localStorage` — no server, no database.

---

## Features

### Player-facing
- **Nickname** — one-time setup, persists in localStorage
- **CT pick** — choose 1 of 3 randomly offered formation tactcs; if your final lineup matches, your total score gets a **×1.25 bonus**
- **Draft 11 players** — shown 4 cards at a time, filtered by role constraints. Players are sampled from all 32 WC2026 squads, weighted by star rating
- **Pitch view** — drag-and-drop style slot assignment across 11 supported formations; swap any player from the bench
- **Captain** — tap a slot to assign captaincy (×1.5 multiplier on that player's points)
- **Result screen** — three modes depending on round state:
  - ⏳ **Upcoming** — scores hidden, lineup visible
  - 🔴 **Live** — scores updating in real-time (polls every 60 s)
  - ✅ **Completed** — final scores + Perfect XI from real match data
- **Leaderboard** — ranked by score, with your entry highlighted

### Admin panel (`?page=admin`)
- Password-protected (session-scoped, expires on tab close)
- **Partite tab** — enter per-player stats for every fixture (goals, assists, yellow/red cards, own goals, penalty scored/missed/saved, rigori conceded for GKs). Autosaves with 500 ms debounce
- **Draft registrati tab** — view all submitted drafts, expandable detail per user
- **Impostazioni round tab** — switch round state (upcoming / live / completed), change active round, trigger score recalculation, reset all drafts
- **Score recalculation engine** — reads admin match data, recalculates every player's points from scratch, re-sorts the leaderboard

### Responsive layout
- **Mobile** (< 430 px) — full-screen card flow
- **Tablet** (431 – 1023 px) — full-width, no chrome
- **Desktop** (≥ 1024 px) — fixed 56 px top nav + 240 px left sidebar with leaderboard, scrollable main area

---

## Scoring System

| Event | Points |
|---|---|
| Goal | +3 |
| Assist | +1 |
| Penalty scored | +3 |
| Penalty saved *(GK only)* | +3 |
| Clean sheet *(GK only)* | +1 |
| Win | +1 |
| Draw | 0 |
| Loss | −1 |
| Goal conceded *(GK only)* | −1 per goal |
| Yellow card | −0.5 |
| Red card | −1 |
| Penalty missed | −3 |
| Own goal | −2 |

**Multipliers applied on top:**
- **Captain** → player's raw points × 1.5
- **CT bonus** → total team score × 1.25 (if your final formation matches the CT you picked)

---

## Formations

11 formations supported, all with correct slot positions on the pitch:

`4-4-2` · `4-3-3` · `4-2-3-1` · `4-3-1-2` · `4-1-4-1` · `3-5-2` · `3-4-3` · `3-4-1-2` · `3-5-1-1` · `5-3-2` · `5-4-1`

---

## File Structure

```
fantapick-wc26/
├── index.html              # HTML shell — loads style.css, app.js, GSAP CDN
├── style.css               # All styles (mobile-first, 3 breakpoints)
├── app.js                  # Full game logic (~2100 lines, no dependencies)
└── data/
    ├── squads-complete.json    # 32 teams × 15 players (role, star rating)
    ├── group-results.json      # Group stage standings
    ├── fixtures-r32.json       # Round-of-32 fixtures
    └── round-results.json      # Mock R32 results (goals, assists, cards, etc.)
```

---

## Tech Stack

| Concern | Choice |
|---|---|
| Language | Vanilla JS (ES2020, `'use strict'`) |
| Animations | [GSAP 3.12](https://gsap.com/) via CDN |
| Fonts | Barlow Condensed (titles) + Inter (body) via Google Fonts |
| Persistence | `localStorage` (game state, drafts, leaderboard, match data) |
| Admin auth | `sessionStorage` (expires on tab close) |
| Build step | None — open `index.html` directly or serve statically |
| Deployment | Any static host (Netlify, GitHub Pages, etc.) |

---

## Local Development

```bash
# Python (built-in)
python3 -m http.server 8743
# then open http://localhost:8743

# Node
npx serve .
```

> **Dev mode** — append `?dev` to the URL to bypass the "already drafted" guard and replay the draft flow freely.

---

## Admin Panel

Navigate to `?page=admin`. The default password is:

```
fantapick2026
```

> Change `ADMIN_PASSWORD` in `app.js` before going public.

### Workflow for a live round

1. Set round state to **Live** in *Impostazioni round*
2. As matches finish, open *Partite* and enter stats for each player
3. Hit **Ricalcola punteggi** — scores update instantly for all users
4. When all matches are done, set state to **Concluso** — the Perfect XI is revealed on each result screen

### Admin data fields (per player)

| Field | Description |
|---|---|
| G | Goals scored |
| A | Assists |
| 🟨 | Yellow card |
| 🟥 | Red card |
| Rig✓ | Penalty scored |
| Rig✗ | Penalty missed |
| AutoG | Own goal |
| RigP | Penalty saved *(GK only)* |
| SubitiG | Goals conceded *(GK only)* |

---

## localStorage Keys

| Key | Contents |
|---|---|
| `fantapick_wc26` | User nickname + completed drafts + personal leaderboard |
| `fantapick_wc26_draft_state` | In-progress draft (auto-restored on reload) |
| `fantapick_wc26_round_state` | Active round + state (`upcoming`/`live`/`completed`) |
| `fantapick_wc26_match_data` | Admin-entered match/player statistics |
| `fantapick_wc26_all_drafts` | All users' submitted drafts (source of truth for scores) |

---

## Adding a New Round

1. Add fixture data to `data/` following the same schema as `fixtures-r32.json`
2. Add result mock data (or leave empty) to `round-results.json`
3. Update `CURRENT_ROUND` in `app.js` to the new round key (e.g. `'r16'`)
4. Add the round name to `ROUND_NAMES` in `app.js`
5. In the admin panel, set round state back to **Upcoming** and reset drafts if needed

---

## Deployment

Drag and drop the entire folder (all 4 files + `data/` directory) onto [Netlify Drop](https://app.netlify.com/drop). That's it.

---

## License

MIT
