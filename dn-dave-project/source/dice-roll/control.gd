extends Control

@onready var dice = $CanvasLayer/Dice
@onready var label = $CanvasLayer/Dice/Label
@onready var roll_button = $CanvasLayer/RollButton

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

	# Pass the dice/label to the singleton
	DiceManager.set_scene_nodes(dice, label)

	# Connect button properly
	roll_button.connect("pressed", Callable(self, "_on_roll_button_pressed"))

	print("Dice node:", dice)
	print("Label node:", label)

func _on_roll_button_pressed():
	print("BUTTON PRESSED")
	DiceManager.roll_d20()
	
