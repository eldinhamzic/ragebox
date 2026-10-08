extends Node2D
const Player = preload("res://scripts/player.gd")
const PLATFORMS = [Rect2(0, 470, 540, 70), Rect2(650, 470, 310, 70)]
var player: CharacterBody2D
var deaths = 0
var elapsed = 0.0
var complete = false
var hud: Label

func _ready() -> void:
	configure_inputs()
	for rect in PLATFORMS:
		add_solid(rect)
	# Phaser world bounds: left, right and ceiling, with the bottom open.
	add_solid(Rect2(-40, -40, 40, 800))
	add_solid(Rect2(960, -40, 40, 800))
	add_solid(Rect2(0, -40, 960, 40))
	player = Player.new()
	player.died.connect(func(): deaths += 1)
	add_child(player)
	var canvas = CanvasLayer.new()
	add_child(canvas)
	hud = Label.new()
	hud.position = Vector2(18, 14)
	hud.add_theme_color_override("font_color", Color("eafaff"))
	hud.add_theme_font_size_override("font_size", 16)
	canvas.add_child(hud)
	var controls = Label.new()
	controls.position = Vector2(18, 90)
	controls.text = "A / D or ← / →    •    Space / ↑ jump    •    R restart"
	controls.add_theme_color_override("font_color", Color("93a8c4"))
	controls.add_theme_font_size_override("font_size", 14)
	canvas.add_child(controls)

func configure_inputs() -> void:
	var bindings = {"move_left": [KEY_A, KEY_LEFT], "move_right": [KEY_D, KEY_RIGHT], "jump": [KEY_SPACE, KEY_UP], "restart": [KEY_R]}
	for action in bindings:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in bindings[action]:
			var event = InputEventKey.new()
			event.physical_keycode = key
			if not InputMap.action_has_event(action, event):
				InputMap.action_add_event(action, event)

func add_solid(rect: Rect2) -> void:
	var body = StaticBody2D.new()
	body.position = rect.get_center()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	var collider = CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return
	if not complete:
		elapsed += delta
		# Same finish threshold as Phaser, translated from center to feet.
		if not player.dead and player.position.x > 835 and player.position.y < 510:
			complete = true
			player.set_physics_process(false)
	var minutes = int(elapsed / 60)
	var seconds = fmod(elapsed, 60)
	hud.text = "LEVEL 1-01  •  FIRST STEPS\nDEATHS %d\nTIME %02d:%05.2f" % [deaths, minutes, seconds]
	if complete:
		hud.text += "\nCOMPLETE — R to replay"

func _draw() -> void:
	draw_rect(Rect2(0, 0, 960, 540), Color("1a2233"))
	draw_rect(Rect2(0, 80, 960, 430), Color("202b3e"))
	# Quiet living-room silhouette; non-colliding background.
	rounded(Rect2(260, 250, 600, 170), Color("27354a"), 32)
	rounded(Rect2(300, 215, 520, 85), Color("34445b"), 28)
	draw_rect(Rect2(290, 395, 45, 90), Color("151b29"))
	draw_rect(Rect2(780, 395, 45, 90), Color("151b29"))
	draw_rect(Rect2(0, 510, 960, 30), Color("111722"))
	for rect in PLATFORMS:
		draw_rect(rect, Color("c89b6d"))
		var board = 0
		var x = rect.position.x
		while x < rect.end.x:
			var width = minf(144, rect.end.x - x)
			draw_rect(Rect2(x, 480, width, 53), Color("c89b6d") if board % 2 == 0 else Color("c29468"))
			if board > 0:
				draw_line(Vector2(x, 480), Vector2(x, 533), Color("9b6f498c"), 1)
			draw_line(Vector2(x+12, 492), Vector2(x+width-12, 492), Color("b5825847"), 1)
			x += 144
			board += 1
		draw_rect(Rect2(rect.position.x, 470, rect.size.x, 10), Color("d8b38a"))
		draw_rect(Rect2(rect.position.x, 533, rect.size.x, 7), Color("9b6f49"))
		draw_line(Vector2(rect.position.x, 471), Vector2(rect.end.x, 471), Color("e7c49ea6"), 1)
	draw_rect(Rect2(869, 320, 12, 130), Color("f5f7ff"))
	draw_colored_polygon(PackedVector2Array([Vector2(875,330), Vector2(945,350), Vector2(875,370)]), Color("f05ab2"))
	draw_string(ThemeDB.fallback_font, Vector2(850, 434), "FINISH", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("f05ab2"))

func rounded(rect: Rect2, color: Color, radius: int) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	draw_style_box(style, rect)
