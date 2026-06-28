-- Grant table-level privileges to anon role.
-- RLS policies alone are not sufficient — Postgres also requires GRANT on the table.

grant select, insert, update, delete on public.drafts          to anon;
grant select, insert, update, delete on public.match_data      to anon;
grant select, insert, update, delete on public.round_state     to anon;
grant select, insert, update, delete on public.qualified_teams to anon;
grant select                         on public.rounds          to anon;
