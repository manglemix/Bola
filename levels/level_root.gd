class_name LevelRoot
extends RandomBarrierGrid


export var vertical_leeway := 600.0

var _going_back := false


func _ready():
	var visibility := VisibilityNotifier2D.new()
	var size := Vector2(grid_width, grid_end_height + vertical_leeway)
	visibility.rect = Rect2(- size / 2, size)
	visibility.transform.origin.y = - (grid_end_height + vertical_leeway) / 2
	add_child(visibility)
	# warning-ignore:return_value_discarded
	visibility.connect("screen_exited", self, "_on_screen_exited")
	
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	Replays.capture_thumbnail()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_go_back()


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST or what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		_go_back()


func _go_back():
	_going_back = true
	GameState.win_streak = 0
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://levels/main_menu.tscn")


func _on_screen_exited():
	if _going_back: return
	GameState.lost()


func win():
	GameState.won()
