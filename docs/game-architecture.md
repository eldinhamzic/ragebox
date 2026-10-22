# Ragebox game architecture

- Next.js owns routes, menus, overlays, progress display, and game embedding.
- Godot owns gameplay rendering, physics, camera, input, timers, traps, challenge scoring, and animation.
- `GodotEmbed` mounts a Godot Web export and listens for the small `ragebox-result` postMessage contract.
- Troll Run is data-driven in Godot with reusable player and trap scenes.
- The precision game preserves the existing Stop-at-100 rule and score calculation.
- NestJS is the server boundary for score/session validation; PostgreSQL is the persistence target.
