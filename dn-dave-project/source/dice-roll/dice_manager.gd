extends Node  # Must be Node so it can be AutoLoaded

var dice: AnimatedSprite2D = null
var label: Label = null
var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()

func set_scene_nodes(dice_node: AnimatedSprite2D, label_node: Label):
	dice = dice_node
	label = label_node

func roll_d20(stat_name: String = "") -> Dictionary:
	if dice == null or label == null:
		print("ERROR: Dice or Label nodes not set!")
		return {
			"base_roll": 0,
			"bonus": 0,
			"total": 0
		}

	# SHOW UI
	dice.get_parent().visible = true

	label.text = "Rolling..."

	for i in range(2):
		dice.play("Dice")
		await dice.animation_finished

	var base_roll = rng.randi_range(1, 20)
	var bonus = 0

	if stat_name != "":
		bonus = PlayerStats.get_stat(stat_name)

	var total = base_roll + bonus

	label.text = "Rolled: " + str(base_roll) + " + " + str(bonus) + " = " + str(total)
	print("Roll:", base_roll, "+", bonus, "=", total)

	# OPTIONAL: pause so player can see result
	await get_tree().create_timer(1.0).timeout

	# HIDE UI
	dice.get_parent().visible = false

	return {
		"base_roll": base_roll,
		"bonus": bonus,
		"total": total
	}
	
