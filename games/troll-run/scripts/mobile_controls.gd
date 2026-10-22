extends CanvasLayer

# TouchScreenButton supports simultaneous touches, including move + jump.
const BUTTON_SIZE := 88
const MARGIN := 18
var buttons: Array[TouchScreenButton] = []

func _ready() -> void:
    layer = 100
    _add_button("move_left", "left")
    _add_button("move_right", "right")
    _add_button("crouch", "down")
    _add_button("jump", "up")
    get_viewport().size_changed.connect(_layout_buttons)
    get_tree().scene_changed.connect(_on_scene_changed)
    _layout_buttons()
    _on_scene_changed(get_tree().current_scene)

func _add_button(action_name: String, symbol: String) -> void:
    var button := TouchScreenButton.new()
    button.action = action_name
    button.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
    button.texture_normal = _make_texture(symbol, false)
    button.texture_pressed = _make_texture(symbol, true)
    button.passby_press = true
    add_child(button)
    buttons.append(button)

func _layout_buttons() -> void:
    var screen_size := get_viewport().get_visible_rect().size
    var y := screen_size.y - BUTTON_SIZE - MARGIN
    buttons[0].position = Vector2(MARGIN, y)
    buttons[1].position = Vector2(MARGIN + BUTTON_SIZE + 14, y)
    buttons[2].position = Vector2(screen_size.x - MARGIN - BUTTON_SIZE * 2 - 14, y)
    buttons[3].position = Vector2(screen_size.x - MARGIN - BUTTON_SIZE, y)

func _on_scene_changed(scene: Node) -> void:
    var playing := scene != null and scene.scene_file_path != "res://scenes/Main.tscn"
    for button in buttons:
        button.visible = playing

func _make_texture(symbol: String, pressed: bool) -> ImageTexture:
    var image := Image.create(BUTTON_SIZE, BUTTON_SIZE, false, Image.FORMAT_RGBA8)
    image.fill(Color.TRANSPARENT)
    var center := Vector2(BUTTON_SIZE / 2.0, BUTTON_SIZE / 2.0)
    var background := Color(0.11, 0.15, 0.24, 0.88 if pressed else 0.67)
    var foreground := Color(0.95, 0.97, 1.0, 1.0)
    for y in range(BUTTON_SIZE):
        for x in range(BUTTON_SIZE):
            var point := Vector2(x, y) - center
            if point.length_squared() > 42.0 * 42.0:
                continue
            var color := background
            if point.length_squared() >= 39.0 * 39.0:
                color = Color(0.7, 0.9, 1.0, 0.92)
            var u := point.x
            var v := point.y
            if symbol == "left" and u <= 13.0 and u >= -16.0 and absf(v) <= (13.0 - u) * 0.62:
                color = foreground
            elif symbol == "right" and u >= -13.0 and u <= 16.0 and absf(v) <= (13.0 + u) * 0.62:
                color = foreground
            elif symbol == "up" and v >= -16.0 and v <= 13.0 and absf(u) <= (13.0 - v) * 0.62:
                color = foreground
            elif symbol == "down" and v >= -13.0 and v <= 16.0 and absf(u) <= (13.0 + v) * 0.62:
                color = foreground
            image.set_pixel(x, y, color)
    return ImageTexture.create_from_image(image)
