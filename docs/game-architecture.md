# RAGEBOX game architecture

- React/Next.js owns routes, menus, overlays, and mounting/unmounting. Phaser owns gameplay, physics, camera, timers, traps, and the in-game HUD.
- `PhaserGame` creates one browser-only Phaser instance and destroys it on unmount. Scenes are passed through a reusable config.
- Precision challenges share `PrecisionResult` and a small registry. `StopAt100` is the first active challenge; future entries can be enabled without changing the menu.
- Troll Run levels are data-first `LevelDefinition` objects. The scene builds rectangular collision geometry and placeholder visuals from that data.
- Traps are created through the small `createTrap` factory and expose `reset()`, so death can restore a level without reloading the page.
- Placeholder rectangles are intentionally separate from collision data. Future sprites can replace the visuals while platform sizes and physics remain stable.
- To add a Troll Run level, create another `LevelDefinition`, then select it from the level menu/config.
- To add a Precision challenge, add registry metadata and a focused challenge component returning `PrecisionResult`.
