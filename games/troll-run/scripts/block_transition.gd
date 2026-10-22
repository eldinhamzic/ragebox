extends Control

func _ready() -> void:
    var block := GameState.current_block + 1
    var next_block := block + 1
    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)
    var column := VBoxContainer.new()
    column.custom_minimum_size = Vector2(360, 0)
    column.add_theme_constant_override("separation", 20)
    center.add_child(column)
    var title := Label.new()
    title.text = "BLOK %d ZAVRŠEN" % block
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 34)
    column.add_child(title)
    if next_block <= GameState.BLOCK_STARTS.size():
        var next := Button.new()
        next.text = "NASTAVI — BLOK %d" % next_block
        next.custom_minimum_size.y = 58
        next.pressed.connect(func() -> void:
            GameState.start_level(next_block - 1, 0, GameState.BLOCK_STARTS[next_block - 1])
        )
        column.add_child(next)
    else:
        var completed := Label.new()
        completed.text = "Sva 30 nivoa završena!"
        completed.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        column.add_child(completed)
    var menu := Button.new()
    menu.text = "GLAVNI MENI"
    menu.custom_minimum_size.y = 54
    menu.pressed.connect(func() -> void: get_tree().change_scene_to_file("res://scenes/Main.tscn"))
    column.add_child(menu)

func _draw() -> void:
    draw_rect(Rect2(Vector2.ZERO, size), Color("0b1427"))
