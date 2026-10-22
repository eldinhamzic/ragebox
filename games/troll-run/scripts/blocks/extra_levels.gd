@tool
extends Node2D

@export_range(4, 5, 1) var block_number := 4
@export_range(1, 6, 1) var level_number := 1
@export_file("*.tscn") var next_level_path := ""
@export var final_level := false

const W := 960.0
const H := 540.0
const START := Rect2(0, 450, 170, 90)
const FINISH := Rect2(820, 450, 140, 90)
var platforms: Array[Rect2] = []
var hazards: Array[Rect2] = []
var completed := false

func _ready() -> void:
    var layout := _layout()
    for entry in layout[0]:
        platforms.append(entry)
    for entry in layout[1]:
        hazards.append(entry)
    if not Engine.is_editor_hint():
        _add_collision(START)
        _add_collision(FINISH)
        for rect in platforms:
            _add_collision(rect)
        $Player.died.connect(_on_died)
        if final_level and has_node("ExitLift"):
            $ExitLift.opened.connect(_finish_block)
    queue_redraw()

func _process(_delta: float) -> void:
    if Engine.is_editor_hint() or completed:
        return
    var p: RageboxPlayer = $Player
    if p.dead or p.falling_into_hole:
        return
    for trap in hazards:
        if trap.has_point(p.global_position + Vector2(0, -16)):
            p.die()
            return
    if not final_level and p.global_position.x >= FINISH.position.x:
        completed = true
        if next_level_path != "":
            get_tree().change_scene_to_file(next_level_path)

func _finish_block() -> void:
    if completed:
        return
    completed = true
    GameState.complete_block()

func _layout() -> Array:
    var key := block_number * 10 + level_number
    match key:
        41: return [[Rect2(192, 414, 118, 22), Rect2(330, 370, 130, 22), Rect2(492, 390, 104, 22), Rect2(660, 415, 118, 22)], [Rect2(520, 372, 35, 18)]]
        42: return [[Rect2(200, 397, 126, 22), Rect2(365, 323, 124, 22), Rect2(530, 385, 110, 22), Rect2(675, 345, 112, 22)], [Rect2(580, 367, 32, 18)]]
        43: return [[Rect2(190, 410, 125, 22), Rect2(330, 345, 115, 22), Rect2(460, 285, 122, 22), Rect2(615, 345, 140, 22)], [Rect2(670, 327, 35, 18)]]
        44: return [[Rect2(193, 450, 125, 25), Rect2(345, 388, 115, 22), Rect2(485, 350, 120, 22), Rect2(655, 410, 135, 22)], [Rect2(385, 370, 30, 18)]]
        45: return [[Rect2(195, 405, 100, 22), Rect2(330, 340, 105, 22), Rect2(455, 400, 105, 22), Rect2(580, 335, 105, 22), Rect2(710, 405, 90, 22)], [Rect2(610, 317, 30, 18)]]
        46: return [[Rect2(195, 395, 115, 22), Rect2(340, 330, 105, 22), Rect2(470, 370, 110, 22), Rect2(610, 312, 115, 22), Rect2(747, 403, 70, 22)], [Rect2(492, 352, 32, 18)]]
        51: return [[Rect2(190, 400, 135, 22), Rect2(365, 360, 125, 22), Rect2(535, 400, 110, 22), Rect2(680, 430, 110, 22)], [Rect2(395, 342, 35, 18)]]
        52: return [[Rect2(185, 395, 128, 22), Rect2(330, 330, 125, 22), Rect2(470, 265, 125, 22), Rect2(620, 350, 145, 22)], [Rect2(685, 332, 35, 18)]]
        53: return [[Rect2(185, 425, 130, 22), Rect2(345, 380, 125, 22), Rect2(500, 325, 125, 22), Rect2(660, 420, 130, 22)], [Rect2(375, 362, 33, 18), Rect2(540, 307, 33, 18)]]
        54: return [[Rect2(195, 400, 140, 22), Rect2(360, 345, 115, 22), Rect2(515, 380, 115, 22), Rect2(665, 395, 128, 22)], [Rect2(550, 362, 38, 18)]]
        55: return [[Rect2(200, 405, 105, 22), Rect2(320, 335, 110, 22), Rect2(455, 385, 110, 22), Rect2(600, 315, 110, 22), Rect2(730, 410, 78, 22)], [Rect2(340, 317, 28, 18), Rect2(630, 297, 28, 18)]]
        56: return [[Rect2(190, 395, 125, 22), Rect2(345, 328, 120, 22), Rect2(490, 270, 120, 22), Rect2(630, 348, 115, 22), Rect2(760, 412, 55, 22)], [Rect2(385, 310, 30, 18), Rect2(675, 330, 30, 18)]]
    return [[], []]

func _add_collision(rect: Rect2) -> void:
    var body := StaticBody2D.new()
    body.position = rect.position + rect.size / 2.0
    var collider := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = rect.size
    collider.shape = shape
    body.add_child(collider)
    add_child(body)

func _on_died() -> void:
    await get_tree().create_timer(0.8).timeout
    if is_inside_tree():
        GameState.restart_block()

func _draw() -> void:
    var sky := Color("07101d") if block_number == 4 else Color("141525")
    draw_rect(Rect2(0, 0, W, H), sky)
    draw_circle(Vector2(825, 85), 36, Color("bfcfdf") if block_number == 4 else Color("a6a8d3"))
    _draw_ground(START)
    _draw_ground(FINISH)
    for rect in platforms:
        _draw_ground(rect)
    for trap in hazards:
        draw_rect(trap, Color("be4d55"))
        for x in range(int(trap.position.x), int(trap.end.x), 12):
            draw_colored_polygon(PackedVector2Array([Vector2(x, trap.end.y), Vector2(x + 6, trap.position.y), Vector2(x + 12, trap.end.y)]), Color("ef8590"))

func _draw_ground(rect: Rect2) -> void:
    draw_rect(rect, Color("263d32"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, minf(10.0, rect.size.y))), Color("4cae68"))
    draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3)), Color("8bd36d"))
