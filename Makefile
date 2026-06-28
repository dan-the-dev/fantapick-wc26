.PHONY: dev db-start db-stop db-reset \
        seed seed-reset seed-r16 seed-qf seed-sf seed-final \
        seed-fake-drafts seed-fake-drafts-prod \
        seed-reset-prod \
        push-schema

# ── Dev server ───────────────────────────────────────────────
dev:
	@echo "▶ http://localhost:8743"
	python3 -m http.server 8743

# ── Local Supabase (requires Docker + supabase CLI) ──────────
db-start:
	supabase start

db-stop:
	supabase stop

db-reset:
	supabase db reset

# ── Seeds ────────────────────────────────────────────────────
seed: seed-reset

seed-reset:
	bash supabase/seeds/seed.sh reset

seed-r16:
	bash supabase/seeds/seed.sh r16

seed-qf:
	bash supabase/seeds/seed.sh qf

seed-sf:
	bash supabase/seeds/seed.sh sf

seed-final:
	bash supabase/seeds/seed.sh final

seed-fake-drafts:
	psql postgresql://postgres:postgres@localhost:54322/postgres -f supabase/seeds/seed_fake_drafts.sql

seed-fake-drafts-prod:
	psql "$(PROD_DB_URL)" -f supabase/seeds/seed_fake_drafts.sql

seed-reset-prod:
	@echo "⚠️  Reset PRODUZIONE — truncate drafts/match_data/qualified_teams, round_state → upcoming"
	psql "$(PROD_DB_URL)" -c "\
	  truncate public.drafts restart identity cascade; \
	  truncate public.match_data restart identity cascade; \
	  truncate public.qualified_teams; \
	  update public.round_state set state = 'upcoming', updated_at = now();"
	psql "$(PROD_DB_URL)" -f supabase/seeds/_base.sql
	psql "$(PROD_DB_URL)" -f supabase/seeds/match_data_r32.sql
	@echo "✅ Produzione resettata per r32"

# ── Push schema to production ────────────────────────────────
# Set PROD_DB_URL in your shell first:
#   export PROD_DB_URL="postgresql://postgres.pngglilremuetaphpuem:PASSWORD@..."
push-schema:
	supabase db push --db-url "$(PROD_DB_URL)"
