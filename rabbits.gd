extends Spatial

var rabbitsQuantity = 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	

func updateQuantity():
	rabbitsQuantity = rabbitsQuantity + 1
	
func birth(parents, mother):
	var rabbitNew = load("res://rabbit.tscn").instance()
	
	add_child(rabbitNew)
	
	rabbitNew.global_transform.origin = mother.get_node("babySpawner").global_transform.origin
	rabbitNew.energy = mother.traits["reproductiveCost"]
	rabbitNew.name = "rabbit" + str(rabbitsQuantity)
	
	rabbitNew.setTraits(parents, true)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
