extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var speed = 20
var speedRot = 1

var shifted

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.shift:
			shifted = true
	else:
		if shifted:
			shifted = false
func _physics_process(delta):

	if Input.is_action_pressed("left"):
		self.global_translate(self.transform.basis.xform(Vector3(-speed * delta,0,0)))
	if Input.is_action_pressed("backwards"):
		self.global_translate(self.transform.basis.xform(Vector3(0,0,speed * delta)))
	if Input.is_action_pressed("forwards"):
		self.global_translate(self.transform.basis.xform(Vector3(0, 0, -speed * delta)))
	if Input.is_action_pressed("right"):
		self.global_translate(self.transform.basis.xform(Vector3(speed  * delta, 0, 0)))
	if Input.is_action_pressed("up"):
		if shifted:
			self.global_translate(self.transform.basis.xform(Vector3(0, -speed  * delta, 0)))
		else:
			self.global_translate(self.transform.basis.xform(Vector3(0, speed  * delta, 0)))
	if Input.is_action_pressed("rot-left"):
		self.rotate_y(speedRot * delta)
	if Input.is_action_pressed("rot-down"):
		$Camera.rotate_x(-speedRot * delta)
	if Input.is_action_pressed("rot-up"):
		$Camera.rotate_x(speedRot * delta)
	if Input.is_action_pressed("rot-right"):
		self.rotate_y(-speedRot * delta)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
