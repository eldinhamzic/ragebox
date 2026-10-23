@tool
extends "res://scripts/blocks/block01/level01.gd"

# Art-only sandbox built on the original 1.1 movement and floor collision.
const Art := preload("res://scripts/art/pixel_art_kit.gd")
const KINDS := ["hammer", "piano", "spikes", "fly", "dragon", "lift", "bridge", "spring", "button", "wall", "lightning", "falling_ground", "moving_platform", "rising_platform", "stable_platform"]
@export var preview_elements := false
var theme_index := 0

func _ready() -> void:
    next_level_path = ""
    super._ready()

func _process(_delta: float) -> void:
    # Never modify campaign progress or advance to Level02.
    pass

func _on_player_died() -> void:
    # Keep testing local; do not restart the original block.
    deaths += 1

func _unhandled_key_input(event: InputEvent) -> void:
    if event.pressed and not event.echo:
        if event.keycode == KEY_E:
            theme_index = (theme_index + 1) % Art.THEMES.size()
            queue_redraw()
        elif event.keycode == KEY_Q:
            theme_index = (theme_index - 1 + Art.THEMES.size()) % Art.THEMES.size()
            queue_redraw()
        elif event.keycode == KEY_TAB:
            preview_elements = not preview_elements
            queue_redraw()

func _draw() -> void:
    Art.background(self, theme_index)
    if preview_elements:
        # Fifteen shared visual designs displayed in a noninteractive gallery.
        for i in range(KINDS.size()):
            var col := i % 5
            var row := int(i / 5)
            var pos := Vector2(104 + col * 185, 165 + row * 95)
            Art.prop(self, KINDS[i], pos, theme_index)
            draw_string(ThemeDB.fallback_font, pos + Vector2(-70, 34), KINDS[i].replace("_", " ").to_upper(), HORIZONTAL_ALIGNMENT_CENTER, 145, 12, Color("#f6f5e9"))
        Art.ground(self, Rect2(0, 450, 960, 90), theme_index)
    else:
        Art.ground(self, Rect2(0, 450, 960, 90), theme_index)
        # Decorative silhouettes only. Existing colliders are untouched.
        Art.prop(self, "stable_platform", Vector2(345, 364), theme_index)
        Art.prop(self, "bridge", Vector2(525, 403), theme_index)
        Art.prop(self, "spring", Vector2(688, 428), theme_index)
        Art.prop(self, "wall", Vector2(849, 415), theme_index)
    Art.pix(self, 12, 11, 690, 50, Color("#172335", 0.88))
    draw_string(ThemeDB.fallback_font, Vector2(24, 31), "RAGEBOX PIXEL LAB  /  " + Art.THEMES[theme_index].to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#f8ecce"))
    draw_string(ThemeDB.fallback_font, Vector2(24, 51), "Q/E: 10 GROUND STYLES    TAB: ELEMENT GALLERY    ORIGINAL 1.1 SAFE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#cbdae3"))
