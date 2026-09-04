extends Control

@onready var dice = $CanvasLayer/Dice
@onready var label = $CanvasLayer/Dice/Label
@onready var roll_button = $CanvasLayer/RollButton

func _ready() -> void:
	get_tree().paused = true
	PlayerManager.player.visible = false
	##PlayerHUD.visible = false
	PauseMenu.process_mode = Node.PROCESS_MODE_DISABLED

	DiceManager.set_scene_nodes(dice, label)
	print("DiceManager nodes set:", dice, label)

	roll_button.pressed.connect(Callable(self, "_on_roll_button_pressed"))

func _process(delta: float) -> void:
	pass

func _on_roll_button_pressed() -> void:
	print("hello")
	await DiceManager.roll_d20("charisma")
