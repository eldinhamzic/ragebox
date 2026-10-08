# Validation — 8 October 2026

Executed with the official Linux x86_64 Godot 4.4.1 stable binary
(`49a5bc7b6`). No changes were made to the Phaser application.

## Passed

- Headless editor import/parse: exit 0, no script errors.
- Headless main-scene startup (`--quit-after 120`): exit 0, no runtime errors.
- `tests/run_tests.gd`: **19 checks, 0 failures**, exit 0.

The integration checks drive Godot's Input actions and actual 60Hz physics frames:

1. Spawn lands on the floor at y=470.
2. Character drawing retains scale 0.70.
3. Settled idle pose.
4. Ground acceleration reaches 140 px/s.
5. Running pose follows movement.
6. Releasing input stops with 17.69 px of drift (expected roughly 18 px).
7. Reversal brakes before facing/running left.
8. Jump lifts the collision body and enters jump pose.
9. Jump apex matches the 720 px/s / 1750 px/s² arc.
10. Falling and landing poses occur.
11. Holding jump does not cause repeated jumps.
12. Left world wall blocks motion.
13. A full-speed jump launched near x=537 clears the 110 px gap.
14. Walking into the gap causes one death and starts debris animation.
15. Collision body remains frozen while dead.
16. Automatic retry restores spawn and clears debris after 560 ms.
17. The retried player lands normally and retains the death count.
18. Finish freezes the player.
19. Finish stops the elapsed timer.

## Not validated

The environment has no usable graphical display. A virtual-display attempt also
failed to provide an X11 connection. Therefore **rendered pixels, animation
appearance, real keyboard interaction, resizing and subjective movement feel
have not been visually verified**. Headless execution exercises animation state
and gameplay logic but does not run a real drawing renderer. The included
`capture_preview.gd` is an optional tool for the desktop reviewer; its rendered
captures were not validated here.

Godot Web export, browser compatibility/performance, mobile/touch input and
embedding into Next.js were not tested or implemented.

## Migration limits

This copies movement constants and intended level proportions; Godot
`CharacterBody2D` and Phaser Arcade use different collision/integration behavior.
Small differences at ledges and in jump height can occur even with the same
constants. No coyote time, jump buffering or variable-height jumps were added.
The procedural character follows the existing reference; simplified clothing
outlines/debris and anti-aliasing can differ. Approval of a new retro art direction
and whether the movement feels better require a desktop playtest.
