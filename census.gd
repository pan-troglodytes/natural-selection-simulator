extends Spatial

var getDataDelay = 10
var currentTime = 0
var rabbits

func _ready():
	var timer = Timer.new()
	timer.set_one_shot(false)
	
	timer.set_wait_time(getDataDelay)
	timer.connect("timeout", self, "getData")
	
	add_child(timer)
	timer.start()
	rabbits = get_node("../rabbits")
	currentTime = currentTime - getDataDelay
	
	
func getData():
	currentTime = currentTime + getDataDelay
	for rabbit in rabbits.get_children():
		if not rabbit.dead:
			print(rabbit.toString(currentTime))
