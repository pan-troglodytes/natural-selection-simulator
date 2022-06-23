extends StaticBody
var energyMax = 20
var energyMin = 40
var energy
var plants
var ground
var dead = false

func _ready():
	plants = get_node("/root/main/plants")
	ground = get_parent()
	energy = floor(rand_range(energyMin, energyMax))

	
	
func _physics_process(_delta):
	$tag/Viewport/Label.text = str(self) + "\n parent" + str(get_parent()) + "\nlayer: " + str(get_collision_layer())
	
	
func eaten():
	translate(Vector3(0,0,5000))
	var energyToGive = energy
	energy = 0
	dead = true
	$dieTimer.wait_time = 10
	return energyToGive

func _on_dieTimer_timeout():
	if dead:
		queue_free()
	else:
		eaten()
		
