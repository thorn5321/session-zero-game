extends Node2D

@export var music : AudioStream



func _ready() -> void:
	self.y_sort_enabled = true
	PlayerManager.set_as_parent( self )
	LevelManager.level_load_started.connect( _free_level )
	AudioManager.play_music( music )
	DiceManager.set_scene_nodes($CanvasLayer/Dice, $CanvasLayer/Dice/Label)
	print("Dice set in PlayGround scene")
	pass # Replace with function body.



func _free_level() -> void:
	PlayerManager.unparent_player( self )
	queue_free()


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
