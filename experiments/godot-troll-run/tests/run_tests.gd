extends SceneTree
const Level = preload("res://scenes/first_steps.tscn")
const Player = preload("res://scripts/player.gd")
var failures = 0
var checks = 0
var level: Node2D

func _initialize() -> void:
	call_deferred("run")

func check(condition: bool, message: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", message)
	else:
		failures += 1
		push_error("FAIL: " + message)

func ticks(count: int) -> void:
	for i in count:
		await physics_frame
	# Observe after that frame's physics callbacks, not before them.
	await process_frame

func release_controls() -> void:
	for action in ["move_left", "move_right", "jump"]:
		if InputMap.has_action(action):
			Input.action_release(action)

func fresh() -> void:
	release_controls()
	if is_instance_valid(level):
		level.free()
	level = Level.instantiate()
	root.add_child(level)
	await ticks(30)

func run() -> void:
	await fresh()
	var p = level.player
	check(p.is_on_floor() and absf(p.position.y - 470) < 0.02, "spawn lands on first platform at y=470")
	check(p.visual.scale == Vector2(0.7,0.7), "small character scale remains 0.70")
	check(p.visual.state == "idle", "settled animation is idle")
	Input.action_press("move_right")
	await ticks(10)
	check(is_equal_approx(p.velocity.x,140), "ground acceleration reaches 140 px/s")
	check(p.visual.state == "run", "running drives procedural animation")
	var release_x: float = p.position.x
	Input.action_release("move_right")
	await ticks(18)
	var drift: float = p.position.x - release_x
	check(absf(p.velocity.x) < 0.01 and drift > 15 and drift < 22, "release gives controlled stop (~18px drift), measured %.2f" % drift)
	Input.action_press("move_right")
	await ticks(10)
	Input.action_release("move_right")
	Input.action_press("move_left")
	await ticks(10)
	check(p.velocity.x < -120 and p.visual.scale.x < 0, "reversing brakes then faces left")
	release_controls()
	await ticks(20)
	Input.action_press("jump")
	await ticks(2)
	check(not p.is_on_floor() and p.velocity.y < -600 and p.visual.state == "jump", "keyboard jump lifts body and raises arms")
	var takeoff: float = p.position.y
	var highest: float = takeoff
	var saw_fall = false
	var saw_land = false
	for i in 65:
		await ticks(1)
		highest = minf(highest,p.position.y)
		saw_fall = saw_fall or p.visual.state == "fall"
		saw_land = saw_land or p.visual.state == "land"
	check(highest < 335 and highest > 315, "jump arc apex matches 720/1750 physics")
	check(saw_fall and saw_land and p.is_on_floor(), "falling and landing poses occur")
	check(p.is_on_floor() and absf(p.velocity.y) < 0.01, "holding jump does not auto-bounce")
	Input.action_release("jump")
	await fresh()
	p = level.player
	# Left world edge.
	Input.action_press("move_left")
	await ticks(90)
	check(p.position.x >= 8.99 and p.position.x < 10, "left world bound blocks player")
	await fresh()
	p = level.player
	p.position.x = 537
	p.velocity.x = 140
	Input.action_press("move_right")
	Input.action_press("jump")
	await ticks(52)
	check(p.position.x > 650 and p.is_on_floor() and level.deaths == 0, "first gap can be crossed with a running jump")
	release_controls()
	await fresh()
	p = level.player
	p.position.x = 530
	Input.action_press("move_right")
	var saw_dead = false
	for i in 55:
		await ticks(1)
		if p.dead:
			saw_dead = true
			break
	check(saw_dead and level.deaths == 1 and p.visual.state == "dead", "walking into gap triggers one death and pieces")
	release_controls()
	var frozen: Vector2 = p.position
	await ticks(15)
	check(p.dead and p.position == frozen, "body remains frozen during death animation")
	await ticks(20)
	check(not p.dead and p.position.x == 100 and p.visual.pieces.is_empty(), "automatic retry after 560ms restores spawn and clears pieces")
	await ticks(25)
	check(p.is_on_floor() and level.deaths == 1, "retried player collides normally and death count persists")
	p.position.x = 840
	await ticks(2)
	check(level.complete and not p.is_physics_processing(), "finish freezes gameplay")
	var finished_time: float = level.elapsed
	await ticks(4)
	check(level.elapsed == finished_time, "completed timer stops")
	level.free()
	print("RESULT: %d checks, %d failures" % [checks,failures])
	quit(0 if failures == 0 else 1)
