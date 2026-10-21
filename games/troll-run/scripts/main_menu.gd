extends Control

const LEVEL_PATHS := [
    "res://scenes/blocks/block01/Level01.tscn",
    "res://scenes/blocks/block01/Level02.tscn",
    "res://scenes/blocks/block01/Level03.tscn",
    "res://scenes/blocks/block01/Level04.tscn",
    "res://scenes/blocks/block01/Level05.tscn",
    "res://scenes/blocks/block01/Level06.tscn",
]

const LEVEL_NAMES := [
    "Nivo 1  ·  Ravno hodanje",
    "Nivo 2  ·  Velika kosina",
    "Nivo 3  ·  Propadajuća zemlja",
    "Nivo 4  ·  Duga kosina i praznina",
    "Nivo 5  ·  Padajući mostovi",
    "Nivo 6  ·  Lebdeće platforme i šiljci",
]

const BLOCK2_LEVEL_PATHS := [
    "res://scenes/blocks/block02/Level01.tscn",
    "res://scenes/blocks/block02/Level02.tscn",
    "res://scenes/blocks/block02/Level03.tscn",
    "res://scenes/blocks/block02/Level04.tscn",
    "res://scenes/blocks/block02/Level05.tscn",
    "res://scenes/blocks/block02/Level06.tscn",
]

const BLOCK2_LEVEL_NAMES := [
    "Nivo 1  ·  Bijela cigla, propadanje i šiljci",
    "Nivo 2  ·  Most stabilan do sredine",
    "Nivo 3  ·  Dugme, klavir ili stepenice",
    "Nivo 4  ·  Zid i opruga",
    "Nivo 5  ·  Propadanje i šiljci",
    "Nivo 6  ·  Posljednja prepreka",
]

var level_panel: VBoxContainer
var block_panel: VBoxContainer

func _ready() -> void:
    _build_menu()

func _build_menu() -> void:
    var background := ColorRect.new()
    background.color = Color("0b1427")
    background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(background)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)

    var column := VBoxContainer.new()
    column.custom_minimum_size = Vector2(560, 0)
    column.add_theme_constant_override("separation", 12)
    center.add_child(column)

    var title := Label.new()
    title.text = "RAGEBOX"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 42)
    title.add_theme_color_override("font_color", Color("8bd36d"))
    column.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "Izaberi blok za igranje ili brzo testiranje nivoa"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    subtitle.add_theme_font_size_override("font_size", 18)
    subtitle.add_theme_color_override("font_color", Color("d9e2e3"))
    column.add_child(subtitle)

    block_panel = VBoxContainer.new()
    block_panel.add_theme_constant_override("separation", 8)
    column.add_child(block_panel)
    _show_blocks()

    level_panel = VBoxContainer.new()
    level_panel.add_theme_constant_override("separation", 8)
    column.add_child(level_panel)

func _show_blocks() -> void:
    _clear_children(block_panel)
    var label := Label.new()
    label.text = "BLOKOVI"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22)
    block_panel.add_child(label)

    var block_one := _make_button("BLOK 1   ·   6 NIVOA", false)
    block_one.pressed.connect(_show_levels.bind(0))
    block_panel.add_child(block_one)

    var block_two := _make_button("BLOK 2   ·   MOSTOVI", false)
    block_two.pressed.connect(_show_levels.bind(1))
    block_panel.add_child(block_two)


func _show_levels(block_index: int) -> void:
    _clear_children(level_panel)
    var label := Label.new()
    label.text = "BLOK 1 — IZABERI NIVO" if block_index == 0 else "BLOK 2 — IZABERI NIVO"
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 22)
    level_panel.add_child(label)

    var paths: Array = LEVEL_PATHS if block_index == 0 else BLOCK2_LEVEL_PATHS
    var names: Array = LEVEL_NAMES if block_index == 0 else BLOCK2_LEVEL_NAMES
    for index in range(paths.size()):
        var button := _make_button(names[index], false)
        button.pressed.connect(_start_level.bind(block_index, index, paths[index]))
        level_panel.add_child(button)

    var back := _make_button("← Nazad na blokove", false)
    back.pressed.connect(_show_blocks)
    level_panel.add_child(back)

func _start_level(block_index: int, level_index: int, scene_path: String) -> void:
    GameState.start_level(block_index, level_index, scene_path)

func _make_button(text_value: String, is_disabled: bool) -> Button:
    var button := Button.new()
    button.text = text_value
    button.disabled = is_disabled
    button.custom_minimum_size = Vector2(560, 42)
    button.add_theme_font_size_override("font_size", 17)
    return button

func _clear_children(node: Node) -> void:
    for child in node.get_children():
        child.queue_free()
