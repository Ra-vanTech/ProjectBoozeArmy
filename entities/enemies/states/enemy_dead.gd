class_name EnemyDeadState
extends State

@export var parent: EnemyBase

var xp_orb: PackedScene = load("res://entities/drops/xp_drop/XpDrop.tscn")
var beer_drop: PackedScene = load("res://entities/drops/beer_drop/BeerDrop.tscn")


func enter():
	var new_xp_orb = xp_orb.instantiate() as XpDrop
	new_xp_orb.global_position = parent.global_position + Vector3(randi_range(-1, 1), 0, randi_range(-1, 1))
	new_xp_orb.bonus_amount = parent.xp_value
	parent.add_sibling(new_xp_orb)

	print(beer_drop)

	var beer_chance = randi_range(0, 3)
	if beer_chance == 1:
		print(beer_drop)
		var beer = beer_drop.instantiate() as BeerDrop
		print(beer == null)
		beer.global_position = parent.global_position + Vector3(randi_range(-1, 1), 0, randi_range(-1, 1))
		beer.bonus_amount = 15
		parent.add_sibling(beer)
	# parent.enemy_died.emit(parent.xp_value)
	parent.queue_free()
