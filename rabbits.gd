extends Spatial

var rabbitsQuantity = 0

func updateQuantity():
	rabbitsQuantity = rabbitsQuantity + 1
	
func birth(parents, mother):
	var rabbitNew = load("res://rabbit.tscn").instance()
	
	add_child(rabbitNew)
	
	rabbitNew.global_transform.origin = mother.get_node("babySpawner").global_transform.origin
	rabbitNew.energy = mother.traits["reproductiveCost"]
	rabbitNew.name = "rabbit" + str(rabbitsQuantity)
	
