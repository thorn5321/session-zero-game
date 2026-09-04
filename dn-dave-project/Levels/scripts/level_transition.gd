@tool
class_name LevelTransition extends Area2D

signal entered_from_here

enum SIDE { LEFT, RIGHT, TOP, BOTTOM }

@export_file( "*.tscn" ) var level
@export_file("*.tscn") var alternate_level
@export var target_transition_area : String = "LevelTransition"
@export var required_flag_name : String = ""
@export var alternate_target_transition_area : String = ""
@export var center_player : bool = false
@export_file("*.tscn") var second_alternate_level
@export var second_required_flag_name : String = ""
@export var second_alternate_target_transition_area : String = ""
@export var spawn_only: bool = false

@export_category("Collision Area Settings")

@export_range( 1, 12, 1, "or_greater") var size : int = 2 :
	set( _v ):
		size = _v
		_update_area()

@export var side: SIDE = SIDE.LEFT :
	set( _v ):
		side = _v
		_update_area()

@export var snap_to_grid : bool = false :
	set ( _v ):
		_snap_to_grid()

@onready var collision_shape: CollisionShape2D = $CollisionShape2D




func _ready() -> void:
	_update_area()
	if Engine.is_editor_hint():
		return
	
	monitoring = false
	_place_player()
	
	await LevelManager.level_loaded
	
	# Some extra physics frame awaits will avoid issues related to frame rate
	# & physics process frame rate not syncing up... we had a bug where no matter
	# what we did the collision would still sometimes happen at the players
	# OLD position after loading on PC's running the game at 120 or 144fps
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	if spawn_only:
		return
	
	monitoring = true
	body_entered.connect( _player_entered )
	
	pass



func _player_entered(_p: Node2D) -> void:
	var next_level = level
	var target_name = target_transition_area

	print("=== LEVEL TRANSITION DEBUG ===")
	print("required_flag_name:", required_flag_name)
	print("flag value:", GameState.get_flag(required_flag_name))
	print("default level:", level)
	print("alternate level:", alternate_level)
	print("default target:", target_transition_area)
	print("alternate target:", alternate_target_transition_area)

	if second_required_flag_name != "" and GameState.get_flag(second_required_flag_name):
		if second_alternate_level != null and second_alternate_level != "":
			next_level = second_alternate_level
		if second_alternate_target_transition_area != "":
			target_name = second_alternate_target_transition_area
		print("USING SECOND ALTERNATE")

	elif required_flag_name != "" and GameState.get_flag(required_flag_name):
		if alternate_level != null and alternate_level != "":
			next_level = alternate_level
		if alternate_target_transition_area != "":
			target_name = alternate_target_transition_area
		print("USING FIRST ALTERNATE")

	else:
		print("USING DEFAULT")

	print("FINAL LEVEL:", next_level)
	print("FINAL TARGET:", target_name)

	LevelManager.load_new_level(next_level, target_name, get_offset())
	pass
	
func _place_player() -> void:
	if name != LevelManager.target_transition:
		return

	var spawn_pos := global_position

	match side:
		SIDE.LEFT:
			spawn_pos.x -= 64
		SIDE.RIGHT:
			spawn_pos.x += 64
		SIDE.TOP:
			spawn_pos.y -= 64
		SIDE.BOTTOM:
			spawn_pos.y += 64

	PlayerManager.set_player_position(spawn_pos)
	entered_from_here.emit()




	match side:
		SIDE.LEFT:
			spawn_pos.x += 16
		SIDE.RIGHT:
			spawn_pos.x -= 16
		SIDE.TOP:
			spawn_pos.y += 16
		SIDE.BOTTOM:
			spawn_pos.y -= 16

	PlayerManager.set_player_position(spawn_pos)
	entered_from_here.emit()


func get_offset() -> Vector2:
	return Vector2.ZERO



func _update_area() -> void:
	var new_rect : Vector2 = Vector2( 32, 32 )
	var new_position : Vector2 = Vector2.ZERO
	
	if side == SIDE.TOP:
		new_rect.x *= size
		new_position.y -= 16
	elif side == SIDE.BOTTOM:
		new_rect.x *= size
		new_position.y += 16
	elif side == SIDE.LEFT:
		new_rect.y *= size
		new_position.x -= 16
	elif side == SIDE.RIGHT:
		new_rect.y *= size
		new_position.x += 16
	
	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
	
	collision_shape.shape.size = new_rect
	collision_shape.position = new_position


func _snap_to_grid() -> void:
	position.x = round( position.x / 16 ) * 16
	position.y = round( position.y / 16 ) * 16
