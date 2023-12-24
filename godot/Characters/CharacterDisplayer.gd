## Displays and animates [Character] portraits, for example, entering from the left or the right.
## Place it behind a [TextBox].
class_name CharacterDisplayer
extends Node

## Emitted when the characters finished displaying or finished their animation.
signal display_finished

## Maps animation text ids to a function that animates a character sprite.
const ANIMATIONS := {"enter": "_enter", "leave": "_leave"}
const SIDE := {LEFT = "left", RIGHT = "right"}
const COLOR_WHITE_TRANSPARENT = Color(1.0, 1.0, 1.0, 0.0)

## Keeps track of the character displayed on either side.
var _displayed := {left = null, right = null}

@onready var _left_sprite: Sprite2D = $Left
@onready var _right_sprite: Sprite2D = $Right


func _ready() -> void:
	_left_sprite.hide()
	_right_sprite.hide()


func _unhandled_input(event: InputEvent) -> void:
	# If the player presses enter before the character animations ended, we seek to the end.
	# TODO
	#if event.is_action_pressed("ui_accept") and _tween.is_active():
		#_tween.seek(INF)
	pass


func display(character: Character, side: String = SIDE.LEFT, expression := "", animation := "") -> void:
	# Keeps track of a character that's already displayed on a given side
	var sprite: Sprite2D = _left_sprite if side == SIDE.LEFT else _right_sprite
	if character == _displayed.left:
		sprite = _left_sprite
	elif character == _displayed.right:
		sprite = _right_sprite
	else:
		_displayed[side] = character

	sprite.texture = character.get_image(expression)

	if animation != "":
		call(ANIMATIONS[animation], side, sprite)

	sprite.show()


## Fades in and moves the character to the anchor position.
func _enter(from_side: String, sprite: Sprite2D) -> void:
	var offset := -200 if from_side == SIDE.LEFT else 200

	var start := sprite.position + Vector2(offset, 0.0)
	var end := sprite.position

	var tween = create_tween()
	tween.set_parallel()
	
	(tween.tween_property(sprite, "position", end, 0.5)
		.from(start)
		.set_ease(Tween.EASE_OUT)
		.set_trans(Tween.TRANS_QUINT))
		
	(tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)
		.from(COLOR_WHITE_TRANSPARENT)
		.set_ease(Tween.EASE_IN_OUT)
		.set_trans(Tween.TRANS_LINEAR))
		
	tween.finished.connect(_on_tween_finished)

	# Set up the sprite
	# We don't use Tween.seek(0.0) here since that could conflict with running tweens and make them jitter back and forth
	sprite.position = start
	sprite.modulate = COLOR_WHITE_TRANSPARENT


func _leave(from_side: String, sprite: Sprite2D) -> void:
	var offset := -200 if from_side == SIDE.LEFT else 200

	var start := sprite.position
	var end := sprite.position + Vector2(offset, 0.0)

	var tween = create_tween() 
	tween.set_parallel()

	(tween.tween_property(sprite, "position", end, 0.5)
		.from(start)
		.set_trans(Tween.TRANS_QUINT)
		.set_ease(Tween.EASE_OUT))
		
	(tween.tween_property(sprite, "modulate", COLOR_WHITE_TRANSPARENT, 0.25)
		.from(Color.WHITE)
		.set_trans(Tween.TRANS_LINEAR)
		.set_ease(Tween.EASE_OUT)
		.set_delay(0.25))
		
	tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	emit_signal("display_finished")
