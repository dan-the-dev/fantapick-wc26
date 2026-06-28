.PHONY: dev db-start db-stop db-reset \
        seed seed-reset seed-r16 seed-qf seed-sf seed-final \
        seed-fake-drafts seed-fake-drafts-prod \
        seed-reset-local seed-reset-prod \
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

seed-reset-local:
	bash supabase/seeds/seed.sh reset "postgresql://postgres:postgres@127.0.0.1:54322/postgres"

seed-reset-prod:
	@echo "⚠️  Reset PRODUZIONE — assicurati di avere DB_PASS settato"
	bash supabase/seeds/seed.sh reset "postgresql://postgres.pngglilremuetaphpuem:$(DB_PASS)@aws-1-eu-north-1.pooler.supabase.com:5432/postgres"

# ── Push schema to production ────────────────────────────────
# Set PROD_DB_URL in your shell first:
#   export PROD_DB_URL="postgresql://postgres.pngglilremuetaphpuem:PASSWORD@..."
push-schema:
	supabase db push --db-url "$(PROD_DB_URL)"
