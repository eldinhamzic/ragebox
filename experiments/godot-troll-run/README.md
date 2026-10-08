# Troll Run — standalone Godot experiment

A small Godot 4.4+ project for evaluating Troll Run movement and procedural
character presentation. No changes to the Next.js/Phaser application, dependencies,
menus, precision challenges, accounts or progress systems.

## Play

1. In Godot 4.4 or later, choose **Import** and select this folder's `project.godot`.
2. Press **F6** with `scenes/first_steps.tscn` open, or **F5** to run the project.
3. Move with **A/D** or **Left/Right**, jump with **Space** or **Up**.
4. **R** restarts the experiment, including its timer and death count.

Walk into the gap to check death/retry. Jump near the edge at full speed to clear
it. The finish freezes the player and timer; press R to replay.
Keyboard controls only in this experiment. No Node.js, .NET, plugins, external
textures, assets, or services are required.

## Reference and translation

Reference: `eldinhamzic/ragebox` master commit
`47a66767d574c97d733bc1cb998618ed8013153b`.

- `src/game/troll-run/scenes/TrollRunScene.ts`: movement, body and retry.
- `src/game/troll-run/scenes/createTrollConfig.ts`: world gravity.
- `src/game/troll-run/player/PlayerVisual.ts`: poses and proportions.
- `src/game/troll-run/levels/first-steps.ts`: level layout.
- `src/game/troll-run/platforms/createPlatform.ts`: laminate presentation.

| Property | Godot experiment |
| --- | --- |
| Logical viewport | 960 × 540; canvas scales with window |
| Platforms | `(0,470,540,70)` and `(650,470,310,70)` |
| Gap | 110 px, no traps |
| Player body | 18 × 50 rectangle, independent of drawing |
| Spawn | centre `(100,400)` → feet `(100,425)` |
| Maximum run speed | 140 px/s |
| Ground acceleration / reversal brake | 1500 / 2300 px/s² |
| Ground friction | 520 px/s² |
| Air acceleration / reversal brake | 950 / 1300 px/s² |
| No air input | horizontal velocity retained |
| Jump speed | 720 px/s upward, new press on ground only |
| Gravity | 1750 px/s² = world 900 + body boost 850 |
| Visual scale / stride distance | 0.70 / 54 px |
| Landing duration | 130 ms |
| Retry delay | 560 ms |
| Death threshold | sprite centre y > 558 → feet y > 583 |
| Finish threshold | x > 835 and feet y < 510 |
| World boundaries | left, right, ceiling solid; bottom open |

The stickman has a red shirt/cap, shorts, small shoes, two-link legs, visible
arm swings and raised arms on jumps. Idle breathing, run bob, airborne poses,
landing crouch and fading scattered death pieces follow the Phaser reference.
The living-room silhouette and laminate floor are retained as a quiet baseline.
This is a behavioral migration experiment, not a new art direction or a finished
retro sprite set. Some clothing shapes and death-piece speeds are simplified.

## Structure

- `scripts/player.gd`: `CharacterBody2D`, momentum, jump, death/retry.
- `scripts/player_visual.gd`: drawing, pose state and cosmetic debris only.
- `scripts/first_steps.gd`: first level, world solids, timer and finish.
- `scenes/first_steps.tscn`: runnable entry scene.
- `tests/run_tests.gd`: automated physics and lifecycle checks.
- `tests/capture_preview.gd`: optional rendered pose smoke test.

Tune physics constants in `player.gd`. Tune proportions and poses in
`player_visual.gd`; its drawing cannot modify the collision body.

## Validate

```sh
godot --headless --path . --editor --quit
godot --headless --path . --script res://tests/run_tests.gd
```

For rendered previews, run with a display, not `--headless`:

```sh
TROLL_RUN_PREVIEW_DIR=/absolute/existing/output/folder \
  godot --path . --script res://tests/capture_preview.gd
```

The preview script captures idle, running, jumping, falling, landing and death.
See `VALIDATION.md` for the actual checks and limits of this delivery.

## Browser evaluation later

This project uses GDScript and the Compatibility renderer so it can be evaluated
with Godot's Web export. Install matching Godot export templates and create a
Web export preset in the editor. Use a local HTTP server to serve the exported
files; do not open the HTML through `file://`. Web export and integration into
the Next.js site are outside this experiment and have not been validated.
