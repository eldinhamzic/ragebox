extends Control

const NEXT_BLOCK_PATH := "res://scenes/blocks/block02/Level01.tscn"

func _ready() -> void:
    var title := Label.new()
    title.text = "BLOK 1 ZAVRŠEN"
    title.position = Vector2(280, 150)
    title.size = Vector2(400, 60)
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", Color("ffffff"))
    add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Spreman za unutrašnjost?"
    subtitle.position = Vector2(280, 225)
    subtitle.size = Vector2(400, 36)
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 18)
    subtitle.add_theme_color_override("font_color", Color("b8b8b8"))
    add_child(subtitle)

    var continue_button := Button.new()
    continue_button.text = "NASTAVI DALJE"
    continue_button.position = Vector2(350, 305)
    continue_button.size = Vector2(260, 64)
    continue_button.add_theme_font_size_override("font_size", 20)
    continue_button.pressed.connect(_continue_to_block_two)
    add_child(continue_button)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color("05070d"))
    draw_rect(Rect2(0, 0, size.x, 16), Color("f5f5f5"))
    draw_rect(Rect2(0, size.y - 16, size.x, 16), Color("f5f5f5"))

func _continue_to_block_two() -> void:
    GameState.start_level(1, 0, NEXT_BLOCK_PATH)
