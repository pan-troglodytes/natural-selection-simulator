extends RigidBody


signal reproduce

var target = null
var targetDistance
var state
enum states{
	WANDER,
	CHASE
}
var energy
var seeking
var age = 1
var twist = 0
var greeding = false
var oldPos
var dead = false


var traits = {
	"ageMax" : null,
	"hopForceForwards" : null,
	"hopForceUp" : null,
	"wanderRange" : null,
	"greed" : null,
	"reproductiveThreshold" : null,
	"reproductiveCost" : null,
	"coat" : null,
	"baseColour" : null,
	"patternColour" : null,
	"mutationChance" : null,
	"mutationPotency" : null,
	"species" : null
}

# LAYERS
# layer 0 is the ground
var layerRabbitEat = 1
var layerRabbitReproduce = 2
var layerPlant = 3

func _ready():
	connect("reproduce", get_parent(), "birth")
	state=states.WANDER
	
func _process(_delta):
	if transform == oldPos:
		oldPos = transform
		hop(twist)
	else:
		oldPos = transform
		
		
	if age > traits["ageMax"]:
		die()
	if energy < 1:
		die()
		
	# when it falls down it gets deleted
	if transform.origin.y < -200:
		queue_free()
	
	target = getTarget()
	if target == null:
		state = states.WANDER
	else:
		state = states.CHASE
	
	stateLogic()
	interact()
	$tag/Viewport/Label.text = self.name + "\nlife: " + str(traits["ageMax"]-age) + " energy: " + str(energy)+ "\ngreeding: " + str(greeding) +" target: " + str(target) + "\nseeking: " + str(seeking)
func stateLogic():
	if state == states.WANDER:
		twist = deg2rad(self.get_rotation_degrees().y + rand_range(-traits["wanderRange"], traits["wanderRange"]))
	if state == states.CHASE and target != null:
		twist = atan2(target.global_transform.origin.x - transform.origin.x, target.global_transform.origin.z - transform.origin.z)




func hop(direction):
	set_rotation(Vector3(0, direction, 0))
	
	if $groundChecker.get_collider() != null:
		energy = energy - 1
		age = age + 1
		apply_central_impulse(self.transform.basis.xform(Vector3(0, traits["hopForceUp"], traits["hopForceForwards"])))#self.transform.basis.xform(global_transform.origin)
	else:
		var retreat
		if self.rotation_degrees.y + 180 > 360:
			retreat = self.rotation_degrees.y + 180
		else:
			retreat = self.rotation_degrees.y - 180
		set_rotation(Vector3(0, deg2rad(retreat), 0))

func getTarget():
	var distanceCurrent
	var distanceLowest = null
	
	
	if energy < traits["reproductiveThreshold"]:
		greeding = true
	if energy >= traits["reproductiveThreshold"] + traits["greed"]:
		greeding = false
	
	# can only collide with valid objects (for performance)
	if greeding:
		set_collision_layer_bit(layerRabbitReproduce, false)
		set_collision_layer_bit(layerRabbitEat, true)
		$visionRange.set_collision_mask_bit(layerRabbitReproduce, false)
		$visionRange.set_collision_mask_bit(layerPlant, true)
		$interactionRange.set_collision_mask_bit(layerRabbitReproduce, false)
		$interactionRange.set_collision_mask_bit(layerPlant, true)
		seeking = "plant"
	else:
		set_collision_layer_bit(layerRabbitReproduce, true)
		set_collision_layer_bit(layerRabbitEat, false)
		$visionRange.set_collision_mask_bit(layerRabbitReproduce, true)
		$visionRange.set_collision_mask_bit(layerPlant, false)
		$interactionRange.set_collision_mask_bit(layerRabbitReproduce, true)
		$interactionRange.set_collision_mask_bit(layerPlant, false)
		seeking = "rabbit"
	
	
	var newTarget = null
	for body in $visionRange.get_overlapping_bodies():
		if body.is_in_group(seeking) and body != self:	
			distanceCurrent = getDistance(self, body)
			if distanceLowest == null or distanceCurrent < distanceLowest:
				if seeking == "rabbit":
					if body.energy >= body.traits["reproductiveThreshold"] and body.traits["species"] == self.traits["species"]:
						distanceLowest = distanceCurrent
						newTarget = body
				else:
					distanceLowest = distanceCurrent
					newTarget = body
				
	
	targetDistance = distanceLowest
	return newTarget
	
	
func getDistance(obj1, obj2):
	var pos1 = obj1.transform.origin
	var pos2 = obj2.transform.origin
	return sqrt(pow(pos2.x - pos1.x, 2) + pow(pos2.y - pos1.y, 2) + pow(pos2.z - pos1.z, 2))

func die():
	dead = true
	set_collision_layer_bit(layerRabbitReproduce, false)
	set_collision_layer_bit(layerRabbitEat, false)
	$visionRange.set_collision_mask_bit(layerRabbitReproduce, false)
	$visionRange.set_collision_mask_bit(layerPlant, false)
	$interactionRange.set_collision_mask_bit(layerRabbitReproduce, false)
	$interactionRange.set_collision_mask_bit(layerPlant, false)
	translate(Vector3(900,0,0))


func setTraits(parentTraits, mutation):
	var colours = []
	var nonMutatable = ["species", "mutationChance", "mutationPotency", "coat"]
	for parent in parentTraits:
		for trait in parent:
			if typeof(parent[trait]) == TYPE_VECTOR3:
				colours.append(parent[trait])
	
	# mutation chance and potency must be set before all other genes, as they
	# determine the values of the other genes
	
	if typeof(parentTraits[0]["mutationChance"]) == TYPE_ARRAY:
		traits["mutationChance"] = get_parent().get_parent().getRandom(parentTraits[0]["mutationChance"])
	else:
		traits["mutationChance"] = parentTraits[0]["mutationChance"]
	traits["mutationPotency"] = parentTraits[0]["mutationPotency"]
	
	
	for trait in parentTraits[0]:
		var inheritedTrait = parentTraits[floor(rand_range(0,parentTraits.size()-1))][trait]
		if typeof(inheritedTrait) == TYPE_ARRAY:
			inheritedTrait = get_parent().get_parent().getRandom(inheritedTrait)
		
		var canMutate = rand_range(0, 101) < traits["mutationChance"]
		
		self.traits[trait] = inheritedTrait
		if not trait in nonMutatable and mutation and canMutate:
			if typeof(inheritedTrait) == TYPE_INT:
				if floor(rand_range(0,2)) == 0:
					self.traits[trait] = int(floor(inheritedTrait - (inheritedTrait * traits["mutationPotency"])))
				else:
					self.traits[trait] = int(floor(inheritedTrait + (inheritedTrait * traits["mutationPotency"])))
			elif typeof(inheritedTrait) == TYPE_VECTOR3:
				
				self.traits[trait] = colours[floor(rand_range(0,colours.size()))]
	
	
	energy = traits["reproductiveThreshold"]
	
	var hopRange = traits["hopForceForwards"]*((2*traits["hopForceUp"])/9.8)
	
	$groundChecker.transform.origin = Vector3(0, 30, hopRange)
	
	var coatFile = File.new()
	coatFile.open(traits["coat"], File.READ)
	var buffer = coatFile.get_buffer(coatFile.get_len())
	coatFile.close()
	var coatImage = Image.new()
	coatImage.load_png_from_buffer(buffer)
	var coatTexture = ImageTexture.new()
	coatTexture.create_from_image(coatImage)
	
	
	var shdr = Shader.new()
	
	shdr.set_code("shader_type spatial; uniform sampler2D coatTex;uniform vec3 baseColor;uniform vec3 patternColor;void fragment() {vec4 albedoTex = texture(coatTex, UV);if (albedoTex.rgb == vec3(0.0, 0.0, 0.0)) {ALBEDO = baseColor} else {ALBEDO = patternColor}}")
	var shader = ShaderMaterial.new()
	shader.set_shader(shdr)
	
	
	$rabbitMesh.material_override = shader
	$rabbitMesh.material_override.set_shader_param("patternColor", traits["patternColour"])
	$rabbitMesh.material_override.set_shader_param("baseColor", traits["baseColour"])
	$rabbitMesh.material_override.set_shader_param("coatTex", coatTexture)

	get_parent().updateQuantity()
	
func interact():
	for body in $interactionRange.get_overlapping_bodies():
		if body != null && body == target:
			
			if body.is_in_group("rabbit"):
				
				if energy > body.energy and body.energy >= body.traits["reproductiveThreshold"] and body.traits["species"] == self.traits["species"]:
					body.energy = body.energy - traits["reproductiveCost"]
					energy = energy - traits["reproductiveCost"]
					
					emit_signal("reproduce", [self.traits, target.traits], self)

		
					target = null
			elif body.is_in_group("plant"):
				
				energy = energy + target.eaten()
				
				target = null

func _on_hopDelay_timeout():
	if transform == oldPos:
		oldPos = transform
		hop(twist)
	else:
		oldPos = transform

func toString(time):
	var output = ""
	output = str(name) + "," + \
	str(energy) + "," + \
	str(age) + "," + \
	str(transform.origin.x) + "," + \
	str(transform.origin.y) + "," + \
	str(transform.origin.z) + ","
	for trait in traits:
		if "Colour" in trait:
			output = output + str(traits[trait].x)+","+str(traits[trait].y)+","+str(traits[trait].z)+","
		else:
			output = output + str(traits[trait]) + ","
	output = output + str(time)	
	return output
