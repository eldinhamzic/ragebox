extends Node2D

const INK := Color("171329")
const CYAN := Color("64e7ef")
const PINK := Color("f05ab2")
var value := 0.0
var result: Dictionary = {}
var holding := false

func _ready() -> void:
    queue_redraw()

func _process(delta: float) -> void:
    if holding and result.is_empty():
        value = minf(120.0, value + delta * 34.0)
        queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("charge") and result.is_empty():
        holding = true
    if event.is_action_released("charge") and holding:
        holding = false
        _finish()

func _finish() -> void:
    var accuracy := absf(100.0 - value)
    var score := maxi(0, roundi(1000.0 - accuracy * 35.0))
    result = {"challengeId": "stop-at-100", "value": value, "accuracy": accuracy, "score": score, "passed": accuracy <= 5.0}
    _send_result(result)
    queue_redraw()

func _send_result(payload: Dictionary) -> void:
    if OS.has_feature("web"):
        JavaScriptBridge.eval("window.parent.postMessage({type:'ragebox-result',result:" + JSON.stringify(payload) + "}, '*');")

func _draw() -> void:
    draw_rect(Rect2(0, 0, 960, 540), INK)
    draw_string(ThemeDB.fallback_font, Vector2(50, 62), "RAGEBOX // PRECISION", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, CYAN)
    draw_string(ThemeDB.fallback_font, Vector2(50, 112), "STOP AT 100%", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(50, 156), "HOLD SPACE OR CLICK — RELEASE ON THE TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9ca1c9"))
    var bar := Rect2(70, 245, 820, 34)
    draw_rect(bar, Color("090a12"))
    draw_rect(Rect2(bar.position, Vector2(bar.size.x * minf(1.0, value / 120.0), bar.size.y)), CYAN)
    draw_line(Vector2(bar.position.x + bar.size.x * 100.0 / 120.0, 228), Vector2(bar.position.x + bar.size.x * 100.0 / 120.0, 296), Color.WHITE, 3)
    draw_string(ThemeDB.fallback_font, Vector2(70, 325), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9ca1c9"))
    draw_string(ThemeDB.fallback_font, Vector2(465, 325), "100 TARGET", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(850, 325), "120", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("9ca1c9"))
    draw_string(ThemeDB.fallback_font, Vector2(70, 410), "%0.2f%%" % value, HORIZONTAL_ALIGNMENT_LEFT, -1, 56, PINK)
    if not result.is_empty():
        draw_string(ThemeDB.fallback_font, Vector2(70, 470), "SCORE %d / 1000 — PRESS R TO TRY AGAIN" % result.score, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)
    else:
        draw_string(ThemeDB.fallback_font, Vector2(70, 470), "BEST WHEN YOU STOP THINKING", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color("9ca1c9"))

func _input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_R and not result.is_empty():
        value = 0.0
        result = {}
        queue_redraw()
