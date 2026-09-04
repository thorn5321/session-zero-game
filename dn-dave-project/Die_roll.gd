extends Control

@onready var dice = $Dice
@onready var label = $Label

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func roll_d20():
	dice.play("roll")
	await dice.animation_finished

	var roll = rng.randi_range(1, 20)
	label.text = "You rolled: " + str(roll)


func _on_roll_button_pressed() -> void:
	roll_d20()
