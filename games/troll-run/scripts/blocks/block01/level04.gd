@tool
extends Node2D

## Level 04: a hard climb, a hidden collapsing summit, a short descent,
## then two airborne ground bridges over a final gap.

@export_enum("Indoor Black", "Day", "Night") var background_style := "Day" : set = set_background_style
@export_file("*.tscn") var next_level_path := ""

const LEVEL_WIDTH := 960.0
const LEVEL_HEIGHT := 540.0
const CLIMB_END_X := 288.0 # 30% of the playable width.
const SUMMIT_END_X := 432.0
const DESCENT_END_X := 576.0
const FINAL_GROUND_X := 864.0
const START_TOP := 450.0
const SUMMIT_TOP := 162.0
const DESCENT_TOP := 300.0
const PLATFORM_Y := 540.0
const GRASS := Color("4cae68")
const GRASS_LIGHT := Color("8bd36d")
const DIRT := Color("9b5d3f")
const DIRT_DARK := Color("68402f")

var terrain_polygons: Array[PackedVector2Array] = []
var surface_points := PackedVector2Array()
var falling_ground: StaticBody2D
var falling_collision: CollisionShape2D
var falling_started := false
var deaths := 0
var started_at := 0
var completed := false

func _ready() -> void:
	_build_terrain()
	if not Engine.is_editor_hint():
		_build_collisions()
		var camera: Camera2D = $Player.get_node("Camera2D")
		camera.position = Vector2.ZERO
		camera.limit_right = LEVEL_WIDTH
		camera.limit_bottom = LEVEL_HEIGHT
		$Player.died.connect(_on_player_died)
		started_at = Time.get_ticks_msec()
	queue_redraw()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint() or completed:
		return
	if not falling_started and $Player.is_on_floor() and $Player.global_position.x >= CLIMB_END_X and $Player.global_position.x < SUMMIT_END_X and $Player.global_position.y <= SUMMIT_TOP + 24.0:
		_start_falling_ground()
	if falling_started:
		queue_redraw()
	if $Player.global_position.x >= LEVEL_WIDTH - 12.0:
		_complete_level()

func set_background_style(value: String) -> void:
	background_style = value
	queue_redraw()

func _build_terrain() -> void:
	surface_points = PackedVector2Array([
		Vector2(0, START_TOP),
		Vector2(CLIMB_END_X, SUMMIT_TOP),
		Vector2(SUMMIT_END_X, SUMMIT_TOP),
		Vector2(DESCENT_END_X, DESCENT_TOP),
		Vector2(FINAL_GROUND_X, START_TOP),
		Vector2(LEVEL_WIDTH, START_TOP),
	])
	# Fixed terrain exists only under the climb, the short descent, and the exit.
	# The summit section and the long gap are intentionally separate.
	terrain_polygons = [
		PackedVector2Array([
			Vector2(0, PLATFORM_Y), Vector2(CLIMB_END_X, PLATFORM_Y),
			surface_points[1], surface_points[0],
		]),
		PackedVector2Array([
			Vector2(SUMMIT_END_X, PLATFORM_Y), Vector2(DESCENT_END_X, PLATFORM_Y),
			surface_points[3], surface_points[2],
		]),
		PackedVector2Array([
			Vector2(FINAL_GROUND_X, PLATFORM_Y), Vector2(LEVEL_WIDTH, PLATFORM_Y),
			surface_points[5], surface_points[4],
		]),
	]

func _build_collisions() -> void:
	for index in range(terrain_polygons.size()):
		_add_polygon_collision("GroundCollision_%d" % index, terrain_polygons[index])

	# The summit section looks exactly like ordinary earth until it is stepped on.
	falling_ground = StaticBody2D.new()
	falling_ground.name = "FallingSummitGround"
	falling_ground.set_meta("description", "Unmarked collapsing summit ground")
	falling_ground.position = Vector2((CLIMB_END_X + SUMMIT_END_X) / 2.0, SUMMIT_TOP + 45.0)
	falling_collision = CollisionShape2D.new()
	var falling_shape := RectangleShape2D.new()
	falling_shape.size = Vector2(SUMMIT_END_X - CLIMB_END_X, 90.0)
	falling_collision.shape = falling_shape
	falling_ground.add_child(falling_collision)
	add_child(falling_ground)

	var trigger := Area2D.new()
	trigger.name = "FallingSummitGroundTrigger"
	trigger.position = Vector2((CLIMB_END_X + SUMMIT_END_X) / 2.0, SUMMIT_TOP)
	var trigger_collision := CollisionShape2D.new()
	var trigger_shape := RectangleShape2D.new()
	trigger_shape.size = Vector2(SUMMIT_END_X - CLIMB_END_X, 16.0)
	trigger_collision.shape = trigger_shape
	trigger.add_child(trigger_collision)
	trigger.body_entered.connect(_on_falling_ground_body_entered)
	add_child(trigger)

	_add_flying_platform("SafeSkyGroundBridge01", Vector2(650, 330), Vector2(84, 24))
	_add_flying_platform("SafeSkyGroundBridge02", Vector2(770, 390), Vector2(84, 24))

func _add_polygon_collision(node_name: String, polygon: PackedVector2Array) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	var collision := CollisionPolygon2D.new()
	collision.polygon = polygon
	body.add_child(collision)
	add_child(body)

func _add_flying_platform(node_name: String, platform_position: Vector2, platform_size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = node_name
	body.position = platform_position
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = platform_size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)

func _on_falling_ground_body_entered(body: Node2D) -> void:
	if falling_started or not body.has_method("die") or not body.is_on_floor():
		return
	if body.global_position.y > SUMMIT_TOP + 14.0:
		return
	_start_falling_ground()

func _start_falling_ground() -> void:
	if falling_started:
		return
	falling_started = true
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree():
		return
	falling_collision.disabled = true
	var tween := create_tween()
	# Move the complete earth mass below the viewport; nothing remains behind.
	tween.tween_property(falling_ground, "position:y", falling_ground.position.y + (LEVEL_HEIGHT - SUMMIT_TOP + 24.0), 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _on_player_died() -> void:
	deaths += 1
	await get_tree().create_timer(0.8).timeout
	if is_inside_tree():
		GameState.restart_block()

func _complete_level() -> void:
	if completed:
		return
	completed = true
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
		return
	_send_result({"time": (Time.get_ticks_msec() - started_at) / 1000.0, "deaths": deaths})

func _send_result(payload: Dictionary) -> void:
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.parent.postMessage({type:'ragebox-result',result:" + JSON.stringify(payload) + "}, '*');")

func _draw() -> void:
	_draw_background()
	for polygon in terrain_polygons:
		draw_colored_polygon(polygon, DIRT_DARK)
	_draw_falling_ground()
	_draw_terrain_texture()
	_draw_surface_lines()
	_draw_flying_platforms()

func _draw_falling_ground() -> void:
	var section_size := Vector2(SUMMIT_END_X - CLIMB_END_X, LEVEL_HEIGHT - SUMMIT_TOP)
	var center := Vector2((CLIMB_END_X + SUMMIT_END_X) / 2.0, SUMMIT_TOP + section_size.y / 2.0)
	if is_instance_valid(falling_ground):
		center = falling_ground.position + Vector2(0, section_size.y / 2.0 - 45.0)
	var section_rect := Rect2(center - section_size / 2.0, section_size)
	draw_rect(section_rect, DIRT_DARK)

func _draw_flying_platforms() -> void:
	var positions := [Vector2(650, 330), Vector2(770, 390)]
	for index in range(positions.size()):
		var position: Vector2 = positions[index]
		var rect := Rect2(position - Vector2(42, 12), Vector2(84, 24))
		draw_rect(rect, DIRT_DARK)
		draw_rect(Rect2(rect.position + Vector2(0, 8), Vector2(rect.size.x, 16)), DIRT)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 8)), GRASS)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 3)), GRASS_LIGHT)

func _draw_surface_lines() -> void:
	for index in range(surface_points.size() - 1):
		# Index 3 is the intentional gap between the descent and the exit ground.
		if index == 3 or (falling_started and index == 1):
			continue
		draw_line(surface_points[index], surface_points[index + 1], GRASS, 12.0)
		draw_line(surface_points[index], surface_points[index + 1], GRASS_LIGHT, 4.0)

func _draw_terrain_texture() -> void:
	for x in range(12, int(LEVEL_WIDTH), 34):
		var top_y := _surface_y_at(float(x))
		if (falling_started and x >= CLIMB_END_X and x < SUMMIT_END_X) or (x >= SUMMIT_END_X and x < DESCENT_END_X) or (x >= DESCENT_END_X and x < FINAL_GROUND_X):
			continue
		draw_line(Vector2(x, top_y + 28), Vector2(x + 7, minf(top_y + 42, LEVEL_HEIGHT - 8)), DIRT, 3.0)
		draw_line(Vector2(x + 16, top_y + 72), Vector2(x + 23, minf(top_y + 86, LEVEL_HEIGHT - 8)), DIRT, 2.0)

func _surface_y_at(x: float) -> float:
	if x <= CLIMB_END_X:
		return lerpf(START_TOP, SUMMIT_TOP, x / CLIMB_END_X)
	if x <= SUMMIT_END_X:
		return SUMMIT_TOP
	if x <= DESCENT_END_X:
		return lerpf(SUMMIT_TOP, DESCENT_TOP, (x - SUMMIT_END_X) / (DESCENT_END_X - SUMMIT_END_X))
	return START_TOP

func _draw_background() -> void:
	if background_style == "Night":
		draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("0b1427"))
	elif background_style == "Indoor Black":
		draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("05070d"))
	else:
		draw_rect(Rect2(0, 0, LEVEL_WIDTH, LEVEL_HEIGHT), Color("7bcbea"))
		draw_circle(Vector2(820, 86), 42, Color("fff0aa"))
		_draw_cloud(Vector2(150, 108), 1.0)
		_draw_cloud(Vector2(490, 78), 0.8)
		_draw_cloud(Vector2(760, 170), 1.15)

func _draw_cloud(origin: Vector2, cloud_scale := 1.0) -> void:
	var cloud := Color("ffffff", 0.86)
	draw_circle(origin + Vector2(-28, 4) * cloud_scale, 18 * cloud_scale, cloud)
	draw_circle(origin + Vector2(0, -7) * cloud_scale, 26 * cloud_scale, cloud)
	draw_circle(origin + Vector2(29, 4) * cloud_scale, 17 * cloud_scale, cloud)
	draw_rect(Rect2(origin + Vector2(-30, 4) * cloud_scale, Vector2(60, 18) * cloud_scale), cloud)
