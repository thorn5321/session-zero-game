extends Control

@onready var btn_increase = $CanvasLayer/ButtonIncreaseTime
@onready var btn_decrease = $CanvasLayer/ButtonDecreaseTime

func _ready():
	# Connect the buttons to the functions
	btn_increase.pressed.connect(Callable(self, "_on_increase_pressed"))
	btn_decrease.pressed.connect(Callable(self, "_on_decrease_pressed"))

func _on_increase_pressed():
	TimeManager.increase_time()  # Increases by 1 hour by default

func _on_decrease_pressed():
	TimeManager.decrease_time()  # Decreases by 1 hour by default
