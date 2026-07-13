class_name EnemyDeadState
extends State

@export var parent: EnemyBase

var xp_orb: PackedScene = load("res://entities/drops/xp_drop/XpDrop.tscn")
var beer_pickup: PackedScene = load("res://entities/drops/beer_drop/BeerDrop.tscn")


func enter():
	create_drop(xp_orb, parent.xp_value)

	var beer_chance = randi_range(0, 3)
	if beer_chance == 1:
		create_drop(beer_pickup, 15)
		# beer.global_position = parent.global_position + Vector3(randi_range(-1, 1), 0, randi_range(-1, 1))
		# beer.bonus_amount = 15
		# parent.add_sibling(beer)
	# parent.enemy_died.emit(parent.xp_value)
	parent.queue_free()


func create_drop(drop: PackedScene, bonus: int) -> void:
	var new_drop = drop.instantiate() as DropBase
	new_drop.name += str(randi_range(0, 100)) # Evitar duplicación de nombres, no sé si realmente es un problema pero bueno
	# bonus_amount antes de entrar al árbol para que _ready (etiqueta) lo lea
	new_drop.bonus_amount = bonus
	parent.add_sibling(new_drop)
	# global_position después de add_sibling: fuera del árbol no es fiable
	new_drop.global_position = parent.global_position + Vector3(randi_range(-1, 1), 0, randi_range(-1, 1))
