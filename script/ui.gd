extends MarginContainer

export var max_hp = 100
export var max_energy = 1000

var hp = max_hp setget update_hp
var energy = max_energy setget update_energy

export (NodePath) onready var hp_bar = get_node(hp_bar)
export (NodePath) onready var energy_bar = get_node(energy_bar)

func update_hp(value):
	hp = value
	hp_bar.value = value
	
func update_energy(value):
	energy = value
	energy_bar.value = value
