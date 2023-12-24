extends Button

## Emitted when the DelayTimer times out.
signal timer_ticked

@onready var _timer := $DelayTimer


func _ready() -> void:
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	_timer.timeout.connect(_on_DelayTimer_timeout)


func _on_button_down() -> void:
	_timer.start()


func _on_DelayTimer_timeout() -> void:
	emit_signal("timer_ticked")


func _on_button_up() -> void:
	_timer.stop()
