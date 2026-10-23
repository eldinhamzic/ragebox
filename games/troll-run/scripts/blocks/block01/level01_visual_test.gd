@tool
extends "res://scripts/blocks/block01/level01.gd"

# Isolated visual experiment. Do not change the original Level01.
# The inherited Player, ground collision, and movement stay identical.
const SKY := Color("#83c9e6")
const HILL_FAR := Color("#a1b7bb")
const HILL_MID := Color("#658b91")
const HILL_NEAR := Color("#386e71")
const SOIL := Color("#85563b")
const SOIL_SHADE := Color("#654330")
const SOIL_DARK := Color("#45342b")
const TURF := Color("#508c47")
const TURF_LIGHT := Color("#9bc95e")

func _on_player_died() -> void:
    # The preview remains on this scene instead of restarting the campaign.
    deaths += 1

func _process(_delta: float) -> void:
    # Test only: reaching the end must never advance campaign progress.
    pass

func _draw() -> void:
    _draw_pixel_sky()
    _draw_hills()
    _draw_landscape_details()
    for platform in platforms:
        _draw_pixel_ground(platform)
    draw_string(ThemeDB.fallback_font, Vector2(22, 34), "RAGEBOX / VISUAL TEST 1.1", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#203b45"))
    draw_string(ThemeDB.fallback_font, Vector2(22, 54), "ART EXPERIMENT - ORIGINAL LEVEL IS UNCHANGED", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#35565c"))

func _draw_pixel_sky() -> void:
    draw_rect(Rect2(0, 0, 960, 450), SKY)
    draw_rect(Rect2(0, 0, 960, 115), Color("#a7dded"))
    draw_rect(Rect2(0, 115, 960, 95), Color("#94d0e7"))
    draw_rect(Rect2(0, 210, 960, 240), Color("#81bdd4"))
    draw_rect(Rect2(772, 61, 84, 84), Color("#f5d786"))
    draw_rect(Rect2(784, 49, 60, 12), Color("#f5d786"))
    draw_rect(Rect2(784, 145, 60, 12), Color("#f5d786"))
    _cloud(Vector2(135, 88), 1)
    _cloud(Vector2(420, 127), 1)
    _cloud(Vector2(655, 65), 1)

func _cloud(pos: Vector2, scale: int) -> void:
    var white := Color("#f4f3dd")
    draw_rect(Rect2(pos.x, pos.y + 10, 94 * scale, 23 * scale), white)
    draw_rect(Rect2(pos.x + 15, pos.y, 32 * scale, 35 * scale), white)
    draw_rect(Rect2(pos.x + 44, pos.y - 10, 35 * scale, 43 * scale), white)
    draw_rect(Rect2(pos.x + 3, pos.y + 33, 88 * scale, 5 * scale), Color("#badce0"))

func _draw_hills() -> void:
    # Hard-edged silhouettes instead of blurry gradients: pixel-art language.
    draw_colored_polygon(PackedVector2Array([Vector2(0, 370), Vector2(0, 300), Vector2(95, 250), Vector2(205, 320), Vector2(350, 240), Vector2(470, 340), Vector2(600, 255), Vector2(760, 325), Vector2(860, 268), Vector2(960, 316), Vector2(960, 450), Vector2(0, 450)]), HILL_FAR)
    draw_colored_polygon(PackedVector2Array([Vector2(0, 410), Vector2(0, 353), Vector2(150, 310), Vector2(300, 365), Vector2(430, 300), Vector2(580, 375), Vector2(740, 305), Vector2(860, 350), Vector2(960, 317), Vector2(960, 450), Vector2(0, 450)]), HILL_MID)
    draw_colored_polygon(PackedVector2Array([Vector2(0, 450), Vector2(0, 400), Vector2(130, 375), Vector2(260, 422), Vector2(390, 369), Vector2(520, 420), Vector2(680, 375), Vector2(810, 420), Vector2(960, 382), Vector2(960, 450)]), HILL_NEAR)

func _draw_landscape_details() -> void:
    for x in [70, 286, 555, 887]:
        draw_rect(Rect2(x, 345, 13, 105), Color("#33555a"))
        draw_rect(Rect2(x - 22, 337, 55, 14), Color("#284d53"))
        draw_rect(Rect2(x - 12, 322, 38, 16), Color("#35666a"))
        draw_rect(Rect2(x - 3, 312, 21, 11), Color("#4d8081"))
    for x in [200, 490, 722]:
        draw_rect(Rect2(x, 416, 17, 34), Color("#496b57"))
        draw_rect(Rect2(x - 10, 397, 37, 22), Color("#5b9058"))
        draw_rect(Rect2(x - 4, 388, 26, 10), Color("#7bad65"))

func _draw_pixel_ground(platform: Rect2) -> void:
    draw_rect(platform, SOIL_DARK)
    draw_rect(Rect2(platform.position.x, platform.position.y + 13, platform.size.x, platform.size.y - 13), SOIL)
    draw_rect(Rect2(platform.position.x, platform.position.y + 3, platform.size.x, 13), TURF)
    draw_rect(Rect2(platform.position.x, platform.position.y, platform.size.x, 5), TURF_LIGHT)
    var cell := 24
    var left := int(platform.position.x)
    var top := int(platform.position.y)
    for x in range(left, int(platform.end.x), cell):
        var idx := int(x / cell)
        draw_rect(Rect2(x + 3, top + 18, 11, 4), SOIL_SHADE)
        draw_rect(Rect2(x + 14, top + 27 + (idx % 3) * 9, 6, 6), SOIL_DARK)
        draw_rect(Rect2(x + 4, top + 46 + (idx % 2) * 7, 13, 5), SOIL_SHADE)
        draw_rect(Rect2(x + 8, top + 73, 6, 5), Color("#b57a4e"))
        if idx % 4 == 0:
            draw_rect(Rect2(x + 8, top - 4, 4, 7), TURF_LIGHT)
            draw_rect(Rect2(x + 12, top - 7, 3, 8), TURF)
