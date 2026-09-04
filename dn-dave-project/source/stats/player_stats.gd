extends Node

# Base stats
var strength: int = 0
var dexterity: int = 0
var intelligence: int = 0
var charisma: int = 0
var constitution: int = 0
var wisdom: int = 0

func increase_stat(stat_name: String, amount: int = 1):
	match stat_name:
		"strength":
			strength += amount
		"dexterity":
			dexterity += amount
		"constitution":
			constitution += amount
		"wisdom":
			wisdom += amount
		"intelligence":
			intelligence += amount
		"charisma":
			charisma += amount
		_:
			print("Invalid stat:", stat_name)

func get_stat(stat_name: String) -> int:
	match stat_name:
		"strength":
			return strength
		"dexterity":
			return dexterity
		"intelligence":
			return intelligence
		"wisdom":
			return wisdom
		"constitution":
			return constitution
		"charisma":
			return charisma
		_:
			print("Invalid stat:", stat_name)
			return 0
