@tool
extends Node2D

@export_range(3, 6, 1) var level_number := 3
@export_file("*.tscn") var next_level_path := ""
@export var final_level := false

const W := 960.0
const H := 540.0
const GROUND_Y := 450.0
const START := Rect2(0, GROUND_Y, 180, 90)
const FINISH := Rect2(820, GROUND_Y, 140, 90)
const PLATFORM_COLOR := Color("263d32")
const PLATFORM_TOP := Color("4cae68")

var platforms: Array[Rect2] = []
var completed := false

func _ready() -> void:
    platforms = _layout_for_level()
    if not Engine.is_editor_hint():
        _add_collision(START, "StartGround")
        _add_collision(FINISH, "FinishGround")
        for index in range(platforms.size()):
            _add_collision(platforms[index], "Platform%d" % index)
        $Player.died.connect(_on_died)
        if final_level and has_node("IndoorLift"):
            $IndoorLift.opened.connect(_complete_level)
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed or final_level:
        return
    if $Player.global_position.x >= FINISH.position.x:
        _complete_level()

func _layout_for_level() -> Array[Rect2]:
    match level_number:
        3:
            return [Rect2(210, 390, 110, 24), Rect2(360, 330, 110, 24), Rect2(510, 270, 110, 24), Rect2(660, 350, 110, 24)]
        4:
            return [Rect2(220, 360, 120, 24), Rect2(390, 300, 120, 24), Rect2(560, 360, 120, 24), Rect2(710, 300, 80, 24)]
        5:
            return [Rect2(210, 380, 130, 24), Rect2(390, 340, 110, 24), Rect2(540, 300, 110, 24), Rect2(690, 380, 100, 24)]
        _:
            return [Rect2(220, 390, 110, 24), Rect2(380, 330, 110, 24), Rect2(540, 270, 110, 24), Rect2(700, 350, 90, 24)]

func _add_collision(rect: Rect2, name: String) -> void:
    var body := StaticBody2D.new()
    body.name = name
    body.position = rect.position + rect.size / 2.0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collision.shape = shape
    body.add_child(collision)
    add_child(body)

func _on_died() -> void:
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree():
        GameState.restart_block()

func _complete_level() -> void:
    if completed:
        return
    completed = true
    if final_level:
        GameState.complete_block()
    elif next_level_path != "":
        get_tree().change_scene_to_file(next_level_path)

func _draw() -> void:
    draw_rect(Rect2(0, 0, W, H), Color("07101d"))
    draw_circle(Vector2(820, 90), 38, Color("c7d3df"))
    _draw_ground(START)
    _draw_ground(FINISH)
    for platform in platforms:
        draw_rect(platform, PLATFORM_COLOR)
        draw_rect(Rect2(platform.position, Vector2(platform.size.x, 8)), PLATFORM_TOP)

func _draw_ground(rect: Rect2) -> void:
    draw_rect(rect, PLATFORM_COLOR)
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 12)), PLATFORM_TOP)
