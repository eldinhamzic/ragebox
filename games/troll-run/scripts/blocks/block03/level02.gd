@tool
extends Node2D

@export_file("*.tscn") var next_level_path := "res://scenes/blocks/block03/Level03.tscn"
const W := 960.0
const H := 540.0
const START := Rect2(0, 450, 192, 90)
const FINISH := Rect2(850, 450, 110, 90)
const PLATFORMS := [Rect2(300, 380, 80, 24), Rect2(470, 320, 80, 24), Rect2(640, 260, 80, 24)]
var fly_angle := 0.0
var fly_origin := Vector2(480, 220)
var fly_state := "flying"
var fly_pause_left := 0.0
var fly_wait_left := 0.0
var fly_speed := 1.4
var dash_velocity := Vector2.ZERO
var fly_area: Area2D
var completed := false

func _ready() -> void:
	if not Engine.is_editor_hint():
		_add_collision(START, "StartGround")
		_add_collision(FINISH, "FinishGround")
		for i in range(PLATFORMS.size()): _add_collision(PLATFORMS[i], "Platform%d" % i)
		$Player.died.connect(_on_died)
		fly_area = Area2D.new()
		var cs := CollisionShape2D.new()
		var shape := CircleShape2D.new(); shape.radius = 18.0; cs.shape = shape
		fly_area.add_child(cs); fly_area.body_entered.connect(_fly_hit); add_child(fly_area)
		fly_wait_left = randf_range(2.0, 8.0)
	queue_redraw()

func _process(delta: float) -> void:
	if Engine.is_editor_hint() or completed: return
	_update_fly(delta)
	$Fly.position = fly_area.position
	queue_redraw()
	if $Player.global_position.x >= FINISH.position.x: completed = true; get_tree().change_scene_to_file(next_level_path)

func _fly_hit(body: Node2D) -> void:
	if fly_state != "dash" or not body.has_method("die") or body.get("dead") == true:
		return
	var away := (body.global_position - fly_area.position).normalized()
	var distance := fly_area.position.distance_to(body.global_position)
	body.global_position = fly_area.position + away * distance * 1.08
	body.velocity = away * 160.0

func _update_fly(delta: float) -> void:
	if fly_state == "flying":
		fly_wait_left -= delta
		fly_angle += delta * fly_speed
		fly_area.position = fly_origin + Vector2(cos(fly_angle) * 440.0, sin(fly_angle * 2.0) * 110.0)
		if fly_wait_left <= 0.0:
			fly_state = "paused"
			fly_pause_left = 1.0
		return

	if fly_state == "paused":
		fly_pause_left -= delta
		if fly_pause_left <= 0.0:
			var direction: Vector2 = ($Player.global_position - fly_area.position).normalized()
			dash_velocity = direction * (fly_speed * 440.0 * 5.0)
			fly_state = "dash"
		return

	fly_area.position += dash_velocity * delta
	if fly_area.position.x < -40.0 or fly_area.position.x > W + 40.0 or fly_area.position.y < -40.0 or fly_area.position.y > H + 40.0:
		fly_state = "flying"
		fly_wait_left = randf_range(2.0, 8.0)

func _add_collision(rect: Rect2, name: String) -> void:
	var b := StaticBody2D.new(); b.name = name; b.position = rect.position + rect.size / 2.0
	var c := CollisionShape2D.new(); var s := RectangleShape2D.new(); s.size = rect.size; c.shape = s; b.add_child(c); add_child(b)

func _on_died() -> void:
	await get_tree().create_timer(0.8).timeout
	if is_inside_tree(): GameState.restart_block()

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("07101d"))
	draw_circle(Vector2(820, 90), 38, Color("c7d3df"))
	draw_rect(START, Color("263d32")); draw_rect(Rect2(START.position, Vector2(START.size.x, 12)), Color("4cae68"))
	draw_rect(FINISH, Color("263d32")); draw_rect(Rect2(FINISH.position, Vector2(FINISH.size.x, 12)), Color("4cae68"))
	for r in PLATFORMS: draw_rect(r, Color("263d32")); draw_rect(Rect2(r.position, Vector2(r.size.x, 8)), Color("4cae68"))
