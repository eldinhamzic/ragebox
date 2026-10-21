@tool
class_name RageboxTripleSpikes
extends Node2D

## Three independent spikes. Each one reacts only to the player's own contact.

@export_range(1, 3, 1) var spike_count := 3 : set = set_spike_count
@export var spacing := 18.0 : set = set_spacing
@export var spike_height := 34.0 : set = set_spike_height
@export var cycle_duration := 3.2 : set = set_cycle_duration
@export var rise_duration := 0.24 : set = set_rise_duration
@export var active_duration := 0.72 : set = set_active_duration
@export var cycle_offset := 0.0 : set = set_cycle_offset
@export var hidden_until_trigger := false

const INK := Color("241c35")
const SPIKE := Color("d9e2e3")
const SPIKE_LIGHT := Color("ffffff")
const SPIKE_SHADE := Color("8fa7b1")

var phase_time := 0.0
var rise_amounts: Array[float] = []
var triggered: Array[bool] = []
var manual_active := false
var collision_body: StaticBody2D
var collision_shapes: Array[CollisionShape2D] = []

func _ready() -> void:
    _build_collision()
    queue_redraw()

func _process(delta: float) -> void:
    if Engine.is_editor_hint():
        _reset_visuals()
        queue_redraw()
        return
    if hidden_until_trigger or manual_active:
        _trigger_spikes_under_player()
    else:
        _run_independent_cycle(delta)
    _animate_spikes(delta)
    _sync_collision()
    _check_player_hit()
    queue_redraw()

func _reset_visuals() -> void:
    if rise_amounts.size() != spike_count:
        rise_amounts.resize(spike_count)
    if triggered.size() != spike_count:
        triggered.resize(spike_count)
    for index in range(spike_count):
        rise_amounts[index] = 0.0
        triggered[index] = false

func _run_independent_cycle(delta: float) -> void:
    phase_time += delta
    for index in range(spike_count):
        var phase := fmod(phase_time + cycle_offset + index * 0.37, maxf(cycle_duration, 0.1))
        var rise_end := maxf(rise_duration, 0.05)
        var active_end := rise_end + maxf(active_duration, 0.05)
        var amount := 0.0
        if phase < rise_end:
            amount = ease(phase / rise_end, 0.65)
        elif phase < active_end:
            amount = 1.0
        else:
            var fall_progress := (phase - active_end) / maxf(cycle_duration - active_end, 0.05)
            amount = 1.0 - ease(clampf(fall_progress, 0.0, 1.0), 0.65)
        rise_amounts[index] = amount

func _trigger_spikes_under_player() -> void:
    var player: RageboxPlayer = get_tree().current_scene.get_node_or_null("Player") as RageboxPlayer
    if player == null or player.dead or player.falling_into_hole:
        return
    var player_feet_y := player.global_position.y
    if player_feet_y < global_position.y - 6.0 or player_feet_y > global_position.y + 18.0:
        return
    for index in range(spike_count):
        if triggered[index]:
            continue
        var spike_x := global_position.x + (index - (spike_count - 1) / 2.0) * spacing
        if absf(player.global_position.x - spike_x) <= 12.0 and player.velocity.y >= 0.0:
            triggered[index] = true

func _animate_spikes(delta: float) -> void:
    if not hidden_until_trigger and not manual_active:
        return
    for index in range(spike_count):
        if triggered[index]:
            rise_amounts[index] = move_toward(rise_amounts[index], 1.0, delta / maxf(rise_duration, 0.05))

func _check_player_hit() -> void:
    var player: RageboxPlayer = get_tree().current_scene.get_node_or_null("Player") as RageboxPlayer
    if player == null or player.dead or player.falling_into_hole:
        return
    for index in range(spike_count):
        if rise_amounts[index] < 0.05:
            continue
        var spike_x := global_position.x + (index - (spike_count - 1) / 2.0) * spacing
        if absf(player.global_position.x - spike_x) <= 12.0 and player.global_position.y >= global_position.y - 4.0 and player.global_position.y <= global_position.y + 16.0:
            player.die()
            return

func set_spike_count(value: int) -> void:
    spike_count = clampi(value, 1, 3)
    _build_collision()
    queue_redraw()

func set_spacing(value: float) -> void:
    spacing = maxf(value, 8.0)
    _build_collision()
    queue_redraw()

func set_spike_height(value: float) -> void:
    spike_height = maxf(value, 12.0)
    _build_collision()
    queue_redraw()

func set_cycle_duration(value: float) -> void:
    cycle_duration = maxf(value, 0.2)

func set_rise_duration(value: float) -> void:
    rise_duration = maxf(value, 0.05)

func set_active_duration(value: float) -> void:
    active_duration = maxf(value, 0.05)

func set_cycle_offset(value: float) -> void:
    cycle_offset = value

func activate_now() -> void:
    # Arms contact-triggered mode; it does not raise all spikes at once.
    manual_active = true

func _build_collision() -> void:
    if not is_inside_tree():
        return
    if collision_body == null:
        collision_body = StaticBody2D.new()
        collision_body.name = "SpikeCollision"
        add_child(collision_body)
    for child in collision_body.get_children():
        child.queue_free()
    collision_shapes.clear()
    rise_amounts.resize(spike_count)
    triggered.resize(spike_count)
    for index in range(spike_count):
        var collision := CollisionShape2D.new()
        var shape := RectangleShape2D.new()
        shape.size = Vector2(12.0, spike_height * 0.82)
        collision.shape = shape
        collision_shapes.append(collision)
        collision_body.add_child(collision)
        rise_amounts[index] = 0.0
        triggered[index] = false
    _sync_collision()

func _sync_collision() -> void:
    for index in range(collision_shapes.size()):
        var collision := collision_shapes[index]
        var x := (index - (spike_count - 1) / 2.0) * spacing
        collision.position = Vector2(x, -spike_height * rise_amounts[index] * 0.41)
        collision.disabled = rise_amounts[index] < 0.96

func _draw() -> void:
    for index in range(spike_count):
        if rise_amounts[index] <= 0.01:
            continue
        var x := (index - (spike_count - 1) / 2.0) * spacing
        var top := Vector2(x, -spike_height * rise_amounts[index])
        var left := Vector2(x - 9.0, 0)
        var right := Vector2(x + 9.0, 0)
        draw_colored_polygon(PackedVector2Array([left, top, right]), INK)
        draw_colored_polygon(PackedVector2Array([
            Vector2(x - 6.0, -3.0),
            Vector2(x, top.y + 3.0),
            Vector2(x + 6.0, -3.0),
        ]), SPIKE)
        draw_line(Vector2(x - 5.0, -4.0), Vector2(x, top.y + 4.0), SPIKE_LIGHT, 2.0)
        draw_line(Vector2(x + 5.0, -4.0), Vector2(x, top.y + 4.0), SPIKE_SHADE, 2.0)
