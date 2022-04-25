class_name Player
extends BouncyBall


const TOO_STEEP_SCENE: PackedScene = preload("res://ui/too_steep.tscn")
const TOO_STEEP_ANGLE_DIFF := 20.0
const TOO_STEEP_DELAY := 0.5

var _too_steep_delay_timer: Timer


func _ready():
	_too_steep_delay_timer = Timer.new()
	_too_steep_delay_timer.one_shot = true
	add_child(_too_steep_delay_timer)
	# warning-ignore-all:return_value_discarded
	connect("jump_started", self, "_try_vibrate")
	connect("not_landed", self, "_on_not_landed")


func replay(replay: Replay):
	var replayer = get_node("UserInput")
	replayer.set_script(Replayer)
	replayer.load_replay(replay)


func _try_vibrate(_null):
	if not GameState.vibrating: return
	Input.vibrate_handheld(50)


func _on_not_landed(angle: float):
	if angle > deg2rad(max_floor_angle_degrees + TOO_STEEP_ANGLE_DIFF) or not _too_steep_delay_timer.is_stopped(): return
	var instance := TOO_STEEP_SCENE.instance()
	get_tree().current_scene.add_child(instance)
	instance.global_position = global_position
	_too_steep_delay_timer.start(TOO_STEEP_DELAY)
