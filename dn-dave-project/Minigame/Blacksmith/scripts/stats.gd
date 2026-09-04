extends VBoxContainer

@onready var hits_label: Label = $HitsLabel

func _on_game_hits_changed(amount) -> void:
	hits_label.text = str(amount) + " : Anvil Hits"
