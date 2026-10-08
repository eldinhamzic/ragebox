extends Node2D
## Presentation-only procedural stickman, following PlayerVisual.ts poses.
const INK = Color("171923")
const SHIRT = Color("df4052")
const SHORTS = Color("252a37")
const SKIN = Color("f5e9d7")
const SHOE = Color("f5f1e8")
var state = "idle"
var previous_grounded = false
var landing_left = 0.0
var phase = 0.0
var clock = 0.0
var motion = Vector2.ZERO
var pieces: Array[Dictionary] = []
var death_age = 0.0

func advance(dt: float, speed: Vector2, grounded: bool, facing: float) -> void:
	clock += dt
	motion = speed
	scale = Vector2(0.7 * facing, 0.7)
	if state == "dead":
		death_age += dt
		for piece in pieces:
			piece.velocity.y += 950.0 * dt
			piece.position += piece.velocity * dt
			piece.angle += piece.spin * dt
		queue_redraw()
		return
	landing_left = maxf(0, landing_left - dt)
	if grounded and not previous_grounded:
		landing_left = 0.130
	previous_grounded = grounded
	if landing_left > 0:
		state = "land"
	elif not grounded:
		state = "fall" if speed.y > 115 else "jump"
	else:
		state = "run" if absf(speed.x) > 8 else "idle"
	if absf(speed.x) > 8 and grounded:
		phase += absf(speed.x) * dt / 54.0 * TAU
	queue_redraw()

func reset_visual() -> void:
	pieces.clear()
	state = "idle"
	previous_grounded = false
	landing_left = 0
	queue_redraw()

func play_death() -> void:
	if state == "dead":
		return
	state = "dead"
	death_age = 0
	pieces.clear()
	var specs = [["head",0,-99], ["shirt",0,-65], ["shorts",0,-43], ["arm",-12,-68], ["arm",12,-68], ["leg",-7,-31], ["leg",7,-31], ["leg",-10,-13], ["leg",10,-13], ["shoe",-10,-2], ["shoe",10,-2]]
	for spec in specs:
		pieces.append({"kind":spec[0], "position":Vector2(spec[1],spec[2]), "velocity":Vector2(randf_range(-250,250)+55,randf_range(-430,-220)), "angle":0.0, "spin":randf_range(-9,9)})
	queue_redraw()

func leg(hip: Vector2, foot: Vector2) -> PackedVector2Array:
	var distance = clampf(hip.distance_to(foot), 3.01, 56.99)
	var angle = (foot-hip).angle()
	var offset = acos(clampf((27*27 + distance*distance - 30*30)/(54*distance),-1,1))
	var a = hip + Vector2.from_angle(angle-offset)*27
	var b = hip + Vector2.from_angle(angle+offset)*27
	return PackedVector2Array([hip, a if a.x > b.x else b, foot])

func arm(shoulder: Vector2, hand: Vector2, bend: float) -> PackedVector2Array:
	return PackedVector2Array([shoulder, shoulder.lerp(hand,0.52)+Vector2(bend,2), hand])

func foot(p: float, offset: float) -> Vector2:
	return Vector2(sin(p)*24+offset, -maxf(0,sin(p))*12)

func limb(points: PackedVector2Array, alpha: float = 1.0) -> void:
	var color = INK
	color.a = alpha
	draw_polyline(points, color, 3.5, true)
	draw_circle(points[1], 2.5, color)

func shoe(at: Vector2, alpha: float) -> void:
	var color = SHOE
	color.a = alpha
	draw_line(at+Vector2(-3,0),at+Vector2(6,0),INK,7,true)
	draw_line(at+Vector2(-3,0),at+Vector2(6,0),color,5,true)

func _draw() -> void:
	if state == "dead":
		var alpha = clampf(1-(death_age-0.360)/0.260,0,1)
		for piece in pieces:
			draw_set_transform(piece.position, piece.angle)
			var color = INK
			color.a = alpha
			match piece.kind:
				"head":
					draw_circle(Vector2.ZERO,12,Color(SKIN,alpha))
					draw_arc(Vector2.ZERO,12,0,TAU,32,color,2,true)
					draw_rect(Rect2(-9,-11,18,4),Color(SHIRT,alpha))
				"shirt": draw_rect(Rect2(-12,-12,24,24),Color(SHIRT,alpha))
				"shorts": draw_rect(Rect2(-11,-6,22,12),Color(SHORTS,alpha))
				"shoe": draw_line(Vector2(-7,0),Vector2(8,0),Color(SHOE,alpha),6,true)
				_: draw_line(Vector2(0,-13),Vector2(0,13),color,4,true)
		draw_set_transform(Vector2.ZERO)
		return
	var crouch = sin((1-landing_left/0.130)*PI)*10 if state == "land" else 0.0
	var bob = absf(sin(phase*2))*1.4 if state == "run" else (sin(clock*2.5)*0.8 if state == "idle" else 0.0)
	var lean = 3.5 if state == "run" else (2.0 if state == "land" else 0.0)
	var pelvis = Vector2(0,-45+crouch+bob)
	var chest = Vector2(lean,-73+crouch+bob)
	var neck = Vector2(lean,-85+crouch+bob)
	var head = Vector2(lean+1,-99+crouch+bob)
	var lf = Vector2(-7,0)
	var rf = Vector2(7,0)
	var lh = Vector2(-17,chest.y+31)
	var rh = Vector2(17,chest.y+31)
	match state:
		"run":
			lf = foot(phase,-3)
			rf = foot(phase+PI,3)
			lh = Vector2(-14-sin(phase)*20,chest.y+28)
			rh = Vector2(14+sin(phase)*20,chest.y+28)
		"jump":
			if motion.y < -95:
				lf = Vector2(-15,-15)
				rf = Vector2(17,-8)
				lh = Vector2(-15,head.y-24)
				rh = Vector2(17,head.y-27)
			else:
				lf = Vector2(-13,-18)
				rf = Vector2(14,-16)
				lh = Vector2(-24,head.y-8)
				rh = Vector2(25,head.y-10)
		"fall":
			lf = Vector2(-11,-5)
			rf = Vector2(12,-3)
			lh = Vector2(-28,chest.y+6)
			rh = Vector2(29,chest.y+6)
		"land":
			lf = Vector2(-15,0)
			rf = Vector2(15,0)
			lh = Vector2(-24,chest.y+27)
			rh = Vector2(24,chest.y+27)
	var ll = leg(Vector2(-5,pelvis.y),lf)
	var rl = leg(Vector2(5,pelvis.y),rf)
	var la = arm(chest+Vector2(-7,-3),lh,-3)
	var ra = arm(chest+Vector2(7,-3),rh,3)
	limb(rl,0.72)
	limb(ll)
	draw_line(neck,pelvis,INK,3.5,true)
	var lag = clampf(-motion.x*0.012,-3,3)
	var hem = pelvis.y-5+(-1.5 if state in ["jump","fall"] else 0.0)
	var shirt = PackedVector2Array([Vector2(chest.x-14,chest.y-8),Vector2(chest.x+14,chest.y-8),Vector2(11+lag,hem),Vector2(-11+lag,hem)])
	draw_colored_polygon(shirt,SHIRT)
	shirt.append(shirt[0])
	draw_polyline(shirt,Color("7e2432"),1.8,true)
	draw_circle(Vector2(neck.x,chest.y-7),4,INK)
	draw_rect(Rect2(-12,pelvis.y-5,24,11),SHORTS)
	for points in [ll,rl]:
		var end = points[0]+(points[1]-points[0]).normalized()*12
		draw_line(points[0]+Vector2(0,3),end,SHORTS,9,true)
	shoe(rf,0.72)
	shoe(lf,1)
	limb(ra,0.78)
	limb(la)
	for points in [la,ra]:
		draw_line(points[0],points[0].lerp(points[1],0.27),SHIRT,9,true)
		draw_circle(points[2],2.8,INK)
	draw_circle(head,12,SKIN)
	draw_arc(head,12,0,TAU,40,INK,2.5,true)
	draw_circle(head+Vector2(4,-1),1.5,INK)
	draw_arc(head+Vector2(0,-5),8,PI,TAU,20,SHIRT,5,true)
	draw_rect(Rect2(head+Vector2(2,-7),Vector2(12,3)),SHIRT)
