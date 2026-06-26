.PHONY: dev db-start db-stop db-reset \
        seed seed-reset seed-r16 seed-qf seed-sf seed-final \
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

# ── Push schema to production ────────────────────────────────
# Set PROD_DB_URL in your shell first:
#   export PROD_DB_URL="postgresql://postgres.pngglilremuetaphpuem:PASSWORD@..."
push-schema:
	supabase db push --db-url "$(PROD_DB_URL)"
