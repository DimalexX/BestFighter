extends Node

var label: Label
var health = 100 #тут свое значение получи

func take_damage(damage_amount: int):
	health -= damage_amount
	if health <= 0:
		health = 0
		print("You died!")
	else:
		label.text = str(health)
