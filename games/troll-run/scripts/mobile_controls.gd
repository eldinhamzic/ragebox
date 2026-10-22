extends CanvasLayer

# Responsive touch overlay. Each touch ID is tracked separately so running,
# jumping and crouching work together in a mobile browser.
const ACTIONS := ["move_left", "move_right", "crouch", "jump"]
const ARROWS := ["◀", "▶", "▼", "▲"]
var controls: Array[Button] = []
var touches: Dictionary = {}
var active := true

func _ready() -> void:
    layer = 100
    for i in range(ACTIONS.size()):
        var button := Button.new()
        button.text = ARROWS[i]
        button.focus_mode = Control.FOCUS_NONE
        button.mouse_filter = Control.MOUSE_FILTER_IGNORE
        button.add_theme_color_override("font_color", Color.WHITE)
        button.add_theme_color_override("font_hover_color", Color.WHITE)
        button.add_theme_color_override("font_pressed_color", Color.WHITE)
        _style_button(button, false)
        add_child(button)
        controls.append(button)
    get_viewport().size_changed.connect(_layout)
    _layout()
    for button in controls:
        button.visible = true

func _style_button(button: Button, pressed: bool) -> void:
    var style := StyleBoxFlat.new()
    style.bg_color = Color("23618e", 0.74) if pressed else Color("15253a", 0.38)
    style.border_color = Color("ffffff", 0.68) if pressed else Color("ffffff", 0.40)
    style.set_border_width_all(2)
    style.set_corner_radius_all(14)
    style.shadow_color = Color(0, 0, 0, 0.12)
    style.shadow_size = 2
    for kind in ["normal", "hover", "pressed", "focus"]:
        button.add_theme_stylebox_override(kind, style)

func _layout() -> void:
    var view := get_viewport().get_visible_rect().size
    var diameter := clampf(minf(view.x * 0.078, view.y * 0.16), 42.0, 76.0)
    var gap := maxf(7.0, diameter * 0.10)
    var margin := maxf(6.0, diameter * 0.12)
    # Two groups stay apart even on narrow screens.
    if diameter * 4.0 + gap * 2.0 + margin * 2.0 > view.x:
        diameter = maxf(32.0, (view.x - 2.0 * margin - 2.0 * gap) / 4.0)
    var y := view.y - diameter - margin
    var positions := [
        Vector2(margin, y),
        Vector2(margin + diameter + gap, y),
        Vector2(view.x - margin - diameter * 2.0 - gap, y),
        Vector2(view.x - margin - diameter, y)
    ]
    for i in range(controls.size()):
        controls[i].position = positions[i]
        controls[i].size = Vector2(diameter, diameter)
        controls[i].custom_minimum_size = Vector2.ZERO
        controls[i].add_theme_font_size_override("font_size", int(diameter * 0.43))
        controls[i].queue_redraw()

func _input(event: InputEvent) -> void:
    if not active:
        return
    if event is InputEventScreenTouch:
        if event.pressed:
            _set_pointer(event.index, event.position)
        else:
            _clear_pointer(event.index)
    elif event is InputEventScreenDrag:
        _set_pointer(event.index, event.position)
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
        if event.pressed:
            _set_pointer(-1, event.position)
        else:
            _clear_pointer(-1)
    elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
        _set_pointer(-1, event.position)

func _find_action(position: Vector2) -> String:
    for i in range(controls.size()):
        if controls[i].visible and Rect2(controls[i].position, controls[i].size).has_point(position):
            return ACTIONS[i]
    return ""

func _set_pointer(pointer_id: int, position: Vector2) -> void:
    var next_action := _find_action(position)
    var old_action: String = touches.get(pointer_id, "")
    if old_action == next_action:
        return
    if old_action != "":
        touches.erase(pointer_id)
        _update_action(old_action)
    if next_action != "":
        touches[pointer_id] = next_action
        _update_action(next_action)

func _clear_pointer(pointer_id: int) -> void:
    var old_action: String = touches.get(pointer_id, "")
    touches.erase(pointer_id)
    if old_action != "":
        _update_action(old_action)

func _update_action(action: String) -> void:
    var held := false
    for value in touches.values():
        if value == action:
            held = true
            break
    if held:
        Input.action_press(action)
    else:
        Input.action_release(action)
    var index := ACTIONS.find(action)
    if index >= 0:
        _style_button(controls[index], held)

func _release_all() -> void:
    touches.clear()
    for action in ACTIONS:
        _update_action(action)
