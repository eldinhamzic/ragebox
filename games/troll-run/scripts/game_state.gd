extends Node

## Persistent progress and test navigation for the block-based campaign.

const BLOCK_STARTS := [
    "res://scenes/blocks/block01/Level01.tscn",
    "res://scenes/blocks/block02/Level01.tscn",
    "res://scenes/blocks/block03/Level01.tscn",
    "res://scenes/blocks/block04/Level01.tscn",
    "res://scenes/blocks/block05/Level01.tscn",
]

var current_block := 0
var current_level := 0
var unlocked_blocks := 1
var changing_scene := false

func _ready() -> void:
    get_tree().scene_changed.connect(_sync_scene)

func _sync_scene(scene: Node) -> void:
    if scene == null:
        return
    var path := scene.scene_file_path
    for block in range(BLOCK_STARTS.size()):
        var prefix := "res://scenes/blocks/block%02d/Level" % (block + 1)
        if path.begins_with(prefix):
            current_block = block
            current_level = maxi(0, int(path.get_file().trim_prefix("Level").trim_suffix(".tscn")) - 1)
            changing_scene = false
            return


func start_level(block_index: int, level_index: int, scene_path: String) -> void:
    current_block = clampi(block_index, 0, BLOCK_STARTS.size() - 1)
    current_level = maxi(level_index, 0)
    changing_scene = false
    get_tree().change_scene_to_file(scene_path)

func restart_block() -> void:
    if changing_scene:
        return
    changing_scene = true
    get_tree().change_scene_to_file(BLOCK_STARTS[current_block])
    changing_scene = false

func complete_block() -> void:
    unlocked_blocks = maxi(unlocked_blocks, current_block + 2)
    changing_scene = false
    get_tree().change_scene_to_file("res://scenes/BlockTransition.tscn")
