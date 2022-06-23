extends Spatial

var isAnInt = RegEx.new()
var isAFloat = RegEx.new()
var error = ""
var colonies = []



func _ready():
	isAnInt.compile("[0-9]+")
	isAFloat.compile("[+-]?([0-9]*[.])?[0-9]+")
	
	
	# place command line arguments in a dictionary
	var arguments = {}
	var flagCurrent = ""
	var colonyCurrent = -1
	var colonyArgs = false 
	for arg in OS.get_cmdline_args():
		# parse into a dictionary
		if "--" in arg:
			flagCurrent = str(arg)
			if flagCurrent != "--colony":
				arguments[flagCurrent] = ""
				colonyArgs = false
			else:
				colonies.append("")
				colonyCurrent = colonyCurrent + 1
				colonyArgs = true
		else:
			if colonyArgs:
				colonies[colonyCurrent] = colonies[colonyCurrent] + arg + " "
			else:
				arguments[flagCurrent] = arguments[flagCurrent] + arg + " "  # space is added to separate values (but creates a trailing space)
	
	# remove trailing white space
	var trailingSpaceRemoved
	for i in arguments:
		trailingSpaceRemoved = arguments[i]
		trailingSpaceRemoved.erase(trailingSpaceRemoved.length() - 1, 1)
		arguments[i] = trailingSpaceRemoved
	
	for i in colonies.size():
		trailingSpaceRemoved = colonies[i]
		trailingSpaceRemoved.erase(trailingSpaceRemoved.length() - 1, 2)
		colonies[i] = trailingSpaceRemoved
	
	
	
	if not "--terrain" in arguments:
		error = error + "Missing flag: --terrain\n"
	if not "--plants" in arguments:
		error = error + "Missing flag: --plants\n"
	if colonies.size() == 0:
		error = error + "Missing flag: --colony\n"
		
	if error == "":
		terrainInit(arguments["--terrain"])
		plantsInit(arguments["--plants"])
		for colony in colonies:
			rabbitInit(colony)
	else:
		print(error)
		get_tree().quit()

func terrainInit(terrainAttributesArguments):
	var attributesAndErrors = attributesArgumentsToDictionary(terrainAttributesArguments)
	var terrainAttributes = attributesAndErrors[0]
	error = error + attributesAndErrors[1]
	var terrainAttributesValid = {
		"heightMap" : null,
		"amplitude" : null
	}
	
	var heightMapFile = File.new()
	
	for attribute in terrainAttributes:
		if attribute == "heightMap":
			var valueAndError = validateFilePath(attribute, terrainAttributes[attribute])
			terrainAttributesValid[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "amplitude":
			var valueAndError = validateInteger(attribute, terrainAttributes[attribute])
			terrainAttributesValid[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		else:
			error = error + "Invalid attribute: " + attribute + "\n"
	for attribute in terrainAttributesValid:
		if terrainAttributesValid[attribute] == null:
			error = error + "Unspecified attribute: " + attribute + "\n"
	
	if error == "":
		
		$terrain.heightmapInit(getRandom(terrainAttributesValid["heightMap"]), getRandom(terrainAttributesValid["amplitude"]))
		$terrain.generate()
		$terrain.updateChunk()

func plantsInit(plantsAttributesArguments):
	var attributesAndErrors = attributesArgumentsToDictionary(plantsAttributesArguments)
	var plantAttributes = attributesAndErrors[0]
	error = error + attributesAndErrors[1]
	for attribute in plantAttributes:
		if attribute == "energyMax": 
			var valueAndError = validateInteger(attribute, plantAttributes[attribute])
			$terrain.plantEnergyMax = valueAndError[0]
			error = error + valueAndError[1]
		if attribute == "energyMin": 
			var valueAndError = validateInteger(attribute, plantAttributes[attribute])
			$terrain.plantEnergyMin = valueAndError[0]
			error = error + valueAndError[1]
		if attribute == "spawnDelay": 
			var valueAndError = validateFloat(attribute, plantAttributes[attribute])
			$terrain/Timer.set_wait_time(getRandom(valueAndError[0]))
			error = error + valueAndError[1]
	
func rabbitInit(rabbitAttributesArguments):
	var attributesAndErrors = attributesArgumentsToDictionary(rabbitAttributesArguments)
	var rabbitAttributes = attributesAndErrors[0]
	
	error = error + attributesAndErrors[1]
	var rabbitTraits = {
		"ageMax": null,
		"hopForceForwards" : null,
		"hopForceUp" : null,
		"wanderRange" : null,
		"reproductiveThreshold" : null,
		"reproductiveCost" : null,
		"greed" : null,
		"baseColour" : null,
		"patternColour" : null,
		"species" : null,
		"mutationChance" : null,
		"mutationPotency" : null
	}
	var rabbitRules = {
		"quantity" : null,
		"x" : null,
		"z" : null
	}
	
	for attribute in rabbitAttributes:
		if attribute == "quantity": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitRules[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "x": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitRules[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "z": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitRules[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "species": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
			
		elif attribute == "mutationPotency": 
			var valueAndError = validateFloat(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "mutationChance": 
			var valueAndError = validatePercentage(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "ageMax": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "hopForceForwards": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "hopForceUp": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "wanderRange": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "reproductiveThreshold": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "reproductiveCost": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "greed": 
			var valueAndError = validateInteger(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "coat": 
			var valueAndError = validateFilePath(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		elif attribute == "baseColour": 
			var valueAndError = validateColour(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			
			error = error + valueAndError[1]
		elif attribute == "patternColour": 
			var valueAndError = validateColour(attribute, rabbitAttributes[attribute])
			rabbitTraits[attribute] = valueAndError[0]
			error = error + valueAndError[1]
		else:
			error = error + "Invalid attribute: " + attribute + "\n"
			
			
	for attribute in rabbitTraits:
		if rabbitTraits[attribute] == null:
			error = error + "Unspecified attribute: " + attribute + "\n"
	for attribute in rabbitRules:
		if rabbitRules[attribute] == null:
			error = error + "Unspecified attribute: " + attribute + "\n"
	

	var rabbitNew
	
	
	if error == "":
		for rabbit in range(getRandom(rabbitRules["quantity"])):
			rabbitNew = $terrain.spawnObject("res://rabbit.tscn", get_node("rabbits"), getRandom(rabbitRules["x"]), getRandom(rabbitRules["z"]))
			rabbitNew.setTraits([rabbitTraits], false)
			rabbitNew.name = "rabbit" + str($rabbits.rabbitsQuantity)
			$rabbits.rabbitsQuantity +  $rabbits.rabbitsQuantity  + 1
		
		get_node("census").getData()
	else:
		get_tree().quit()
	print(error)



func attributesArgumentsToDictionary(attributesArguments):
	var attributesDictionary = {}
	var errorNew = ""
	for attribute in attributesArguments.split(" "):
		
		var attributeSplit = attribute.split("=")

		if attributeSplit.size() == 2 and attributeSplit[1] != "":
			attributesDictionary[attributeSplit[0]] = str(attributeSplit[1])
		else:
			errorNew = errorNew + "Invalid value for: " + attributeSplit[0] + "\n"
	return [attributesDictionary, errorNew]
		

func validateInteger(attributeName, attributeValue):
	var attributeSplit = attributeValue.split(",")
	var attributesAsArray = []
	var errorNew = ""
	for attribute in attributeSplit:
		attributesAsArray.append(int(attribute))
		if len(attribute) > 5:
			errorNew = errorNew + "Must have a length no greater than 5: " + attributeName + "\n"
		if isAnInt.search(attribute) == null:
			errorNew = errorNew + "Must be an integer (or two separated by a command for a range): " + attributeName + "\n"
	if attributeSplit.size() != 2 and attributeSplit.size() != 1:
		errorNew = errorNew + "Invalid range: " + attributeName + "\n"
	return [attributesAsArray, errorNew]
func validateFloat(attributeName, attributeValue):
	var attributeSplit = attributeValue.split(",")
	var attributesAsArray = []
	var errorNew = ""
	for attribute in attributeSplit:
		attributesAsArray.append(float(attribute))
		if len(attribute) > 8:
			errorNew = errorNew + "Must have a length no greater than 8: " + attributeName + "\n"
		if isAFloat.search(attribute) == null:
			errorNew = errorNew + "Must be a float (or two separated by a command for a range): " + attributeName + "\n"
	if attributeSplit.size() != 2 and attributeSplit.size() != 1:
		errorNew = errorNew + "Invalid range: " + attributeName + "\n"
	return [attributesAsArray, errorNew]
func validatePercentage(attributeName, attributeValue):
	var attributeSplit = attributeValue.split(",")
	var attributesAsArray = []
	var errorNew = ""
	for attribute in attributeSplit:
		attributesAsArray.append(int(attribute))
		if isAnInt.search(attribute) == null:
			errorNew = errorNew + "Must be an integer (or two separated by a command for a range): " + attributeName + "\n"
		if int(attribute) > 100 or int(attribute) < 0:
			errorNew = errorNew + "Must be an integer from 0 to 100" + attributeName + "\n"
	if attributeSplit.size() != 2 and attributeSplit.size() != 1:
		errorNew = errorNew + "Invalid range: " + attributeName + "\n"
	
	return [attributesAsArray, errorNew]
func validateFilePath(attributeName, attributeValue):
	var heightMapFile = File.new()
	var attributeSplit = attributeValue.split(",")
	var attributesAsArray = []
	var errorNew = ""
	for attribute in attributeSplit:
		attributesAsArray.append(str(attribute))
		if !heightMapFile.file_exists(attribute):
			errorNew = errorNew + "File not found: " + attributeValue + "\n"
	return [attributesAsArray, errorNew]
func validateColour(attributeName, attributeValue):
	var attributeSplit = attributeValue.split(".") # each r.g.b colours are serated by "."
	var colours = ["red", "green", "blue"]
	var errorNew = ""
	if attributeSplit.size() != 3:
		errorNew = errorNew + "Invalid colour: " + attributeValue + "\n"
	
	for i in attributeSplit.size():
		if isAnInt.search(attributeSplit[i]) == null:
			errorNew = errorNew + "Invalid " + colours[i] + " in: " + attributeValue + "\n"
		else:
			if int(attributeSplit[i]) < 0 or int(attributeSplit[i]) > 255:
				errorNew = errorNew + "Invalid " + colours[i] + " in: " + attributeValue + "\n"
	
	if errorNew == "":
		attributeValue = Vector3(float(attributeSplit[0])/255, float(attributeSplit[1])/255, float(attributeSplit[2])/255)

	return [attributeValue, errorNew]

func getRandom(attributeRange):
	# get a random value between the given range
	if typeof(attributeRange[0]) == TYPE_INT:
		return int(floor(rand_range(int(attributeRange[0]), int(attributeRange[attributeRange.size()-1]))))
	# get a random value from the list of stirngs
	elif typeof(attributeRange[0]) == TYPE_STRING:
		return attributeRange[int(floor(rand_range(0, attributeRange.size())))]
	# get a random value between the given range as a float
	else: # floats
		return rand_range(attributeRange[0], attributeRange[attributeRange.size()-1])
