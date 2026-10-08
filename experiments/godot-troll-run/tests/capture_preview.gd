extends SceneTree
## Optional renderer smoke test. Run with a display (not --headless).
const Level = preload("res://scenes/first_steps.tscn")
var level: Node2D

func _initialize() -> void:
	call_deferred("capture")

func capture() -> void:
	level = Level.instantiate()
	root.add_child(level)
	for i in 35:
		await physics_frame
	await RenderingServer.frame_post_draw
	var output = OS.get_environment("TROLL_RUN_PREVIEW_DIR")
	if output.is_empty():
		output = "user://"
	var error = root.get_texture().get_image().save_png(output.path_join("first-steps.png"))
	if error != OK:
		push_error("Could not save preview: %s" % error_string(error))
		quit(1)
		return
	# Render each presentation state, including debris, to catch draw-path errors.
	level.player.set_physics_process(false)
	for pose in ["run","jump","fall","land","dead"]:
		var visual = level.player.visual
		visual.state = pose
		visual.phase = 1.0
		visual.motion = Vector2(140,-500 if pose == "jump" else 200)
		visual.landing_left = 0.065 if pose == "land" else 0.0
		if pose == "dead":
			visual.state = "idle"
			visual.play_death()
			visual.advance(0.10,Vector2.ZERO,false,1)
		visual.queue_redraw()
		await process_frame
		await RenderingServer.frame_post_draw
		error = root.get_texture().get_image().save_png(output.path_join(pose+".png"))
		if error != OK:
			quit(1)
			return
	print("Saved idle, run, jump, fall, land and death previews to ", output)
	level.free()
	quit()
