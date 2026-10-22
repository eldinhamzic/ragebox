extends CanvasLayer

# Browser-friendly controls, visible on both mobile and desktop for testing.
const SIZE := Vector2(92, 78)
const GAP := 14.0
const EDGE := 20.0
var controls: Array[Button] = []
var actions := ["move_left", "move_right", "crouch", "jump"]
var labels := ["◀", "▶", "▼", "▲"]

func _ready() -> void:
    layer = 100
    for i in range(actions.size()):
        var button := Button.new()
        button.text = labels[i]
        button.focus_mode = Control.FOCUS_NONE
        button.custom_minimum_size = SIZE
        button.size = SIZE
        button.mouse_filter = Control.MOUSE_FILTER_STOP
        button.add_theme_font_size_override("font_size", 32)
        button.add_theme_color_override("font_color", Color.WHITE)
        var normal := StyleBoxFlat.new()
        normal.bg_color = Color(0.08, 0.13, 0.22, 0.78)
        normal.border_color = Color(0.7, 0.9, 1.0, 0.8)
        normal.set_border_width_all(2)
        normal.set_corner_radius_all(16)
        var pressed := normal.duplicate() as StyleBoxFlat
        pressed.bg_color = Color(0.21, 0.47, 0.69, 0.95)
        button.add_theme_stylebox_override("normal", normal)
        button.add_theme_stylebox_override("hover", normal)
        button.add_theme_stylebox_override("pressed", pressed)
        button.button_down.connect(_press.bind(actions[i]))
        button.button_up.connect(_release.bind(actions[i]))
        add_child(button)
        controls.append(button)
    get_viewport().size_changed.connect(_layout)
    _layout()

func _process(_delta: float) -> void:
    var scene := get_tree().current_scene
    var playing := scene != null and scene.scene_file_path != "res://scenes/Main.tscn"
    for button in controls:
        button.visible = playing
    if not playing:
        for action in actions:
            if Input.is_action_pressed(action):
                Input.action_release(action)

func _layout() -> void:
    var viewport_size := get_viewport().get_visible_rect().size
    var y := viewport_size.y - SIZE.y - EDGE
    controls[0].position = Vector2(EDGE, y)
    controls[1].position = Vector2(EDGE + SIZE.x + GAP, y)
    controls[2].position = Vector2(viewport_size.x - EDGE - SIZE.x * 2.0 - GAP, y)
    controls[3].position = Vector2(viewport_size.x - EDGE - SIZE.x, y)

func _press(action: String) -> void:
    Input.action_press(action)

func _release(action: String) -> void:
    Input.action_release(action)
