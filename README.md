# PyMon

A browser-based serious game for learning Python through Pokemon-inspired gameplay.

Live demo: https://aditfadhillah.github.io/PyMon/

Repository: https://github.com/AditFadhillah/PyMon/

## What it does

- Lets players explore a game world and encounter Pokemon.
- Launches Python programming challenges during encounters.
- Validates solutions in-browser and rewards successful captures.
- Tracks trainer progress, leaderboards, achievements, and sessions.

## Stack

- React + TypeScript + Vite
- Godot (game layer)
- Supabase + PostgreSQL (auth and data)
- Pyodide (Python execution in browser)

## Local development

```bash
npm install
npm run dev
```

Other scripts:

```bash
npm run build
npm run preview
```

## Database setup (fresh project)

Run these SQL files in Supabase SQL Editor in this order:

1. database/database_schema.sql
2. database/cleanup_duplicate_tasks.sql
3. database/add_category_to_tasks.sql
4. database/update_get_random_task_exclude_recent.sql
5. database/create_achievements_table.sql
6. database/usage_sessions_migration.sql
7. database/add_capture_time_column.sql

If signup fails with RLS errors, also run:

8. database/FIX_NEW_USER_SIGNUP_ERRORS.sql

## Environment

Set Supabase values in .env:

- VITE_SUPABASE_URL
- VITE_SUPABASE_ANON_KEY
- SUPABASE_URL
- SUPABASE_ANON_KEY

## Notes

- Current gameplay writes captured Pokemon to public.pokemon_inventory.
- Legacy tables from older backups (for example players or pokemon_stats) are not required for current gameplay flow.