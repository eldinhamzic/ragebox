@tool
class_name RageboxPlayerPreview
extends "res://scripts/player/player.gd"

## Isolated visual prototype for the starting hero.
## This script is intentionally not referenced by the active Player scene.

const INK := Color("24283a")
const HAT_DARK := Color("6b3d25")
const HAT := Color("92552f")
const HAT_LIGHT := Color("b97842")
const SKIN_SHADOW := Color("c97f5f")
const SKIN := Color("f0bd91")
const SHIRT_DARK := Color("9f2f32")
const SHIRT := Color("c9413c")
const SHIRT_LIGHT := Color("e65b45")
const DENIM_DARK := Color("24466e")
const DENIM := Color("356b9e")
const DENIM_LIGHT := Color("5c91b5")
const BELT := Color("6a3c29")
const BUCKLE := Color("dfb04f")
const BOOT := Color("1b2233")
const BOOT_LIGHT := Color("303b51")

func _draw() -> void:
    if animation_state == "death":
        _draw_death_parts()
        return

    var bob := sin(run_phase) * 2.0 if animation_state == "run" else 0.0
    var step := sin(run_phase) * 4.0 if animation_state == "run" else 0.0
    var side := facing
    var crouch_scale := Vector2(1.0, 0.68) if crouching else Vector2.ONE
    draw_set_transform(Vector2(0, 3 if crouching else 0), 0.0, crouch_scale)

    # Compact body and boots. The silhouette stays within the original player footprint.
    _rect(Rect2((-7 + step) * side, -7 + bob, 7 * side, 15), INK)
    _rect(Rect2((-5 + step) * side, -6 + bob, 5 * side, 12), DENIM)
    _rect(Rect2((2 - step) * side, -7 + bob, 7 * side, 15), INK)
    _rect(Rect2((4 - step) * side, -6 + bob, 4 * side, 12), DENIM_DARK)
    _rect(Rect2((-9 + step) * side, 6 + bob, 11 * side, 5), INK)
    _rect(Rect2((-7 + step) * side, 8 + bob, 9 * side, 3), BOOT)
    _rect(Rect2((1 - step) * side, 6 + bob, 12 * side, 5), INK)
    _rect(Rect2((2 - step) * side, 8 + bob, 10 * side, 3), BOOT)
    _rect(Rect2((-5 + step) * side, 10 + bob, 7 * side, 2), BOOT_LIGHT)
    _rect(Rect2((5 - step) * side, 10 + bob, 7 * side, 2), BOOT_LIGHT)

    # Red shirt, shoulder highlights and belt with buckle.
    _rect(Rect2(-12 * side, -25 + bob, 23 * side, 22), INK)
    _rect(Rect2(-9 * side, -22 + bob, 17 * side, 17), SHIRT)
    _rect(Rect2(-7 * side, -21 + bob, 6 * side, 14), SHIRT_LIGHT)
    _rect(Rect2(4 * side, -20 + bob, 4 * side, 13), SHIRT_DARK)
    _rect(Rect2(-9 * side, -8 + bob, 17 * side, 5), BELT)
    _rect(Rect2(-2 * side, -9 + bob, 6 * side, 6), BUCKLE)
    _rect(Rect2(0 * side, -8 + bob, 2 * side, 4), HAT_DARK)

    # Short arms follow the original animation pose.
    var arm_y := -30.0 if animation_state == "jump" else -19.0
    _rect(Rect2(8 * side, arm_y, 7 * side, 13), INK)
    _rect(Rect2(10 * side, arm_y + 2, 4 * side, 8), SHIRT)
    _rect(Rect2(10 * side, arm_y + 9, 4 * side, 3), SKIN)
    if animation_state == "crouch":
        _rect(Rect2(-13 * side, -16, 6 * side, 10), INK)
        _rect(Rect2(-12 * side, -14, 4 * side, 7), SHIRT_DARK)

    # Large head with hair, shaped brown hat and brim.
    _rect(Rect2(-11 * side, -45 + bob, 22 * side, 23), INK)
    _rect(Rect2(-8 * side, -41 + bob, 16 * side, 18), SKIN)
    _rect(Rect2(-8 * side, -41 + bob, 5 * side, 16), SKIN_SHADOW)
    _rect(Rect2(-9 * side, -39 + bob, 3 * side, 10), HAT_DARK)
    _rect(Rect2(7 * side, -36 + bob, 6 * side, 5), SKIN)
    _rect(Rect2(10 * side, -35 + bob, 3 * side, 3), SKIN_SHADOW)

    # Brown hair locks, eyebrow, eye, nose and readable moustache.
    _rect(Rect2(-7 * side, -40 + bob, 4 * side, 7), HAT_DARK)
    _rect(Rect2(-4 * side, -37 + bob, 3 * side, 5), HAT_DARK)
    _rect(Rect2(2 * side, -33 + bob, 5 * side, 2), INK)
    _rect(Rect2(6 * side, -32 + bob, 3 * side, 2), INK)
    _rect(Rect2(8 * side, -30 + bob, 2 * side, 3), INK)
    _rect(Rect2(6 * side, -28 + bob, 5 * side, 3), INK)
    _rect(Rect2(3 * side, -26 + bob, 5 * side, 2), INK)
    _rect(Rect2(7 * side, -29 + bob, 2 * side, 2), SKIN_SHADOW)

    # Hat crown, band, top highlight and broad brim.
    _rect(Rect2(-10 * side, -49 + bob, 19 * side, 8), INK)
    _rect(Rect2(-8 * side, -48 + bob, 15 * side, 6), HAT)
    _rect(Rect2(-6 * side, -49 + bob, 10 * side, 2), HAT_LIGHT)
    _rect(Rect2(-9 * side, -43 + bob, 17 * side, 4), HAT_DARK)
    _rect(Rect2(-7 * side, -43 + bob, 11 * side, 2), HAT_LIGHT)
    _rect(Rect2(2 * side, -42 + bob, 11 * side, 4), INK)
    _rect(Rect2(3 * side, -41 + bob, 9 * side, 2), HAT)

    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _rect(rect: Rect2, color: Color) -> void:
    # Pixel-art rectangles are deliberately aligned to whole pixels and never filtered.
    draw_rect(rect, color)

func _draw_death_parts() -> void:
    for part in death_parts:
        var kind: String = part["kind"]
        draw_set_transform(part["position"], float(part["rotation"]), Vector2.ONE)
        if kind == "head":
            draw_rect(Rect2(-11, -11, 22, 18), _death_color(INK))
            draw_rect(Rect2(-8, -7, 16, 12), _death_color(SKIN))
            draw_rect(Rect2(-10, -13, 19, 6), _death_color(HAT))
            draw_rect(Rect2(4, -3, 7, 3), _death_color(INK))
        elif kind == "body":
            draw_rect(Rect2(-12, -14, 24, 25), _death_color(INK))
            draw_rect(Rect2(-9, -11, 18, 18), _death_color(SHIRT))
            draw_rect(Rect2(-8, 3, 16, 4), _death_color(BELT))
        elif kind == "arm":
            draw_rect(Rect2(-5, -11, 10, 22), _death_color(INK))
            draw_rect(Rect2(-3, -8, 6, 14), _death_color(SHIRT))
        elif kind == "leg":
            draw_rect(Rect2(-5, -9, 10, 18), _death_color(INK))
            draw_rect(Rect2(-4, -5, 8, 10), _death_color(DENIM))
            draw_rect(Rect2(-7, 5, 14, 5), _death_color(BOOT))
        else:
            var shard_size: float = part["size"]
            var shard_color: Color = part["color"]
            shard_color.a = death_alpha
            draw_rect(Rect2(-shard_size * 0.5, -shard_size * 0.5, shard_size, shard_size), shard_color)
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _death_color(color: Color) -> Color:
    var result := color
    result.a = death_alpha
    return result
