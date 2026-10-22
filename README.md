# RAGEBOX

Ragebox is a browser game collection with two Godot 4 games and a Next.js site. The repository is organized as `frontend/`, `backend/`, `games/`, and `database/`; Phaser has been removed.

## Development

Install Node.js 20+, PostgreSQL 16+, and Godot 4.x with the Web export templates.

```powershell
npm install --prefix frontend
npm install --prefix backend
Copy-Item backend/.env.example backend/.env
npm run dev --prefix frontend
npm run start:dev --prefix backend
```

Run PostgreSQL with `docker compose up postgres`. Apply `database/migrations/001_initial_scores.sql` with your PostgreSQL migration runner. Secrets belong in environment variables.

## Godot Web exports

Open each `games/*/project.godot` in Godot and export the Web preset to the matching frontend public directory: `games/troll-run` to `frontend/public/games/troll-run`, and `games/precision-challenge` to `frontend/public/games/precision-challenge`.

Next.js embeds those exports in an iframe. Godot owns physics, rendering, input, animation, camera, traps, and challenge scoring; React owns navigation and result overlays. Games may report results to the parent page with the `ragebox-result` message contract.

## Verification

```powershell
npm run typecheck --prefix frontend
npm run build --prefix frontend
npm run build --prefix backend
```

The local environment used for this migration did not include Godot or its Web export templates, so the exported HTML/WASM bundles cannot be generated here. The Godot sources and export destinations are ready for that final tool-assisted step.

## Migration inventory

- Existing functionality: Next.js menus/routes, local progress, Troll Run movement/platforms/traps, and the Stop-at-100 precision rule.
- Migrated: gameplay ownership moved to `games/troll-run` and `games/precision-challenge`; the website uses `GodotEmbed`.
- Removed: Phaser dependency, Phaser scenes, React gameplay components, and duplicate frontend game logic.
- Added: NestJS score-validation endpoint, PostgreSQL score migration, environment examples, Docker PostgreSQL/Nginx configuration.
- Limitation: server persistence wiring and production Godot Web exports require deployment PostgreSQL credentials and Godot export templates.
