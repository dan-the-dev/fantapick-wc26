#!/usr/bin/env bash
# Usage: bash supabase/seeds/seed.sh [scenario]
# Scenarios: reset (default), r16, qf, sf, final

set -e

SCENARIO=${1:-reset}
VALID=("reset" "r16" "qf" "sf" "final")

if [[ ! " ${VALID[*]} " =~ " ${SCENARIO} " ]]; then
  echo "❌ Scenario sconosciuto: ${SCENARIO}"
  echo "   Validi: ${VALID[*]}"
  exit 1
fi

DB_URL="postgresql://postgres:postgres@127.0.0.1:54322/postgres"
SEEDS_DIR="$(dirname "$0")"

echo "🗑️  Reset database..."
psql "$DB_URL" -q -c "
  truncate table public.drafts       restart identity cascade;
  truncate table public.match_data   restart identity cascade;
  truncate table public.qualified_teams;
  update public.round_state set state = 'upcoming', updated_at = now();
"

echo "🌱 Applico _base..."
psql "$DB_URL" -q -f "${SEEDS_DIR}/_base.sql"

echo "🎬 Applico scenario: ${SCENARIO}..."
psql "$DB_URL" -q -f "${SEEDS_DIR}/scenario_${SCENARIO}.sql"

echo "✅ Seed completato: ${SCENARIO}"
echo "   Apri: http://localhost:8743"
