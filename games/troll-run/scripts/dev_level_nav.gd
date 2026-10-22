extends CanvasLayer

## Development-only level navigation overlay.

const LEVELS := [
    "res://scenes/blocks/block01/Level01.tscn",
    "res://scenes/blocks/block01/Level02.tscn",
    "res://scenes/blocks/block01/Level03.tscn",
    "res://scenes/blocks/block01/Level04.tscn",
    "res://scenes/blocks/block01/Level05.tscn",
    "res://scenes/blocks/block01/Level06.tscn",
    "res://scenes/blocks/block02/Level01.tscn",
    "res://scenes/blocks/block02/Level02.tscn",
    "res://scenes/blocks/block02/Level03.tscn",
    "res://scenes/blocks/block02/Level04.tscn",
    "res://scenes/blocks/block02/Level05.tscn",
    "res://scenes/blocks/block02/Level06.tscn",
    "res://scenes/blocks/block03/Level01.tscn",
    "res://scenes/blocks/block03/Level02.tscn",
    "res://scenes/blocks/block03/Level03.tscn",
    "res://scenes/blocks/block03/Level04.tscn",
    "res://scenes/blocks/block03/Level05.tscn",
    "res://scenes/blocks/block03/Level06.tscn",
]

var panel: PanelContainer
var level_label: Label
var previous_button: Button
var next_button: Button

func _ready() -> void:
    layer = 100
    get_tree().scene_changed.connect(_on_scene_changed)
    call_deferred("_refresh")

func _on_scene_changed() -> void:
    call_deferred("_refresh")

func _refresh() -> void:
    if get_tree().current_scene == null:
        return
    var scene_path := get_tree().current_scene.scene_file_path
    var index := LEVELS.find(scene_path)
    if index < 0:
        if panel != null:
            panel.visible = false
        return
    if panel == null:
        _build_panel()
    panel.visible = true
    level_label.text = "DEV  %02d / %02d" % [index + 1, LEVELS.size()]
    previous_button.disabled = index == 0
    next_button.disabled = index == LEVELS.size() - 1

func _build_panel() -> void:
    panel = PanelContainer.new()
    panel.position = Vector2(8, 8)
    panel.size = Vector2(360, 34)
    panel.mouse_filter = Control.MOUSE_FILTER_STOP
    add_child(panel)

    var row := HBoxContainer.new()
    row.add_theme_constant_override("separation", 5)
    panel.add_child(row)

    level_label = Label.new()
    level_label.custom_minimum_size = Vector2(78, 28)
    level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    row.add_child(level_label)

    previous_button = Button.new()
    previous_button.text = "← PREV"
    previous_button.pressed.connect(_go_previous)
    row.add_child(previous_button)

    next_button = Button.new()
    next_button.text = "NEXT →"
    next_button.pressed.connect(_go_next)
    row.add_child(next_button)

    var restart_button := Button.new()
    restart_button.text = "RESTART"
    restart_button.pressed.connect(func() -> void:
        get_tree().reload_current_scene()
    )
    row.add_child(restart_button)

    var menu_button := Button.new()
    menu_button.text = "MENU"
    menu_button.pressed.connect(func() -> void:
        get_tree().change_scene_to_file("res://scenes/Main.tscn")
    )
    row.add_child(menu_button)

func _current_index() -> int:
    return LEVELS.find(get_tree().current_scene.scene_file_path)

func _go_previous() -> void:
    var index := _current_index()
    if index > 0:
        get_tree().change_scene_to_file(LEVELS[index - 1])

func _go_next() -> void:
    var index := _current_index()
    if index >= 0 and index < LEVELS.size() - 1:
        get_tree().change_scene_to_file(LEVELS[index + 1])
