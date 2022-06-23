extends StaticBody

# vertices of a cube
const vertices = [
	Vector3(0, 0, 0),
	Vector3(1, 0, 0),
	Vector3(0, 1, 0),
	Vector3(1, 1, 0),
	Vector3(0, 0, 1),
	Vector3(1, 0, 1),
	Vector3(0, 1, 1),
	Vector3(1, 1, 1),
]

# faces of a cube

const TOP = [3, 7, 6, 2] # [second vertex, third vertex, seventh vertex, sixth vertex]
const BOTTOM = [0, 4, 5, 1]
const LEFT = [6, 4, 0, 2]
const RIGHT = [3, 1, 5, 7]
const FRONT = [7, 5, 4, 6]
const BACK = [2, 0, 1, 3]

var blocks
var st = SurfaceTool.new()
var mesh = null 
var meshInstance = null

const DIMENSION = Vector3(0, 0, 0)


enum {
	AIR,
	GRASS
}

var heightMap


var plantEnergyMax
var plantEnergyMin
var spawnDelay

var material = preload("res://terrain.tres")


func heightmapInit(heightMapPath, amplitude):
	
	var heightMapFile = File.new()
	heightMapFile.open(heightMapPath, File.READ)
	var buffer = heightMapFile.get_buffer(heightMapFile.get_len())
	heightMapFile.close()
	
	heightMap = Image.new()
	heightMap.load_png_from_buffer(buffer)
	heightMap.lock()
	
	DIMENSION.x = heightMap.get_width()
	DIMENSION.y = int(amplitude)
	DIMENSION.z = heightMap.get_height()
	self.heightMap = heightMap
	
# create the blocks array which contains all the block data
func generate():
	var block = AIR
	blocks = []
	blocks.resize(DIMENSION.x)
	for x in range(0, DIMENSION.x):
		blocks[x] = []
		blocks[x].resize(DIMENSION.y)
		for y in range(0, DIMENSION.y):
			blocks[x][y] = []
			blocks[x][y].resize(DIMENSION.z)
			for z in range(0, DIMENSION.z):
				block = AIR
				var height = int(heightMap.get_pixel(x, z).r * DIMENSION.y)
				#print(heightMap.get_pixel(x, z).r  * DIMENSION.y)
				#print(height)
				if y <= height:
					block = GRASS

				blocks[x][y][z] = block

	
func updateChunk():
	
	mesh = Mesh.new()
	meshInstance = MeshInstance.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in DIMENSION.x:
		for y in DIMENSION.y:
			for z in DIMENSION.z:
				createBlock(x,y,z)
	st.generate_normals(false)
	st.set_material(material)
	st.commit(mesh)
	meshInstance.set_mesh(mesh)
	
	add_child(meshInstance)
	meshInstance.create_trimesh_collision()

func checkAir(x, y, z):
	if x >= 0 and x < DIMENSION.x and \
		y >= 0 and y < DIMENSION.y and \
		z >= 0 and z < DIMENSION.z:
			return blocks[x][y][z] == AIR
	# if on edge return true
	return true

func createBlock(x, y, z):
	var block = blocks[x][y][z]
	if block == AIR:
		return
	# if the above block is air (transparent), render that face, else do not render. this stops the wasteful rendering of visually obstructed faces
	if checkAir(x, y + 1, z):
		createFace(TOP, x, y, z)
	if checkAir(x, y - 1, z):
		createFace(BOTTOM, x, y, z)
	if checkAir(x - 1, y, z):
		createFace(LEFT, x, y, z)
	if checkAir(x + 1, y, z):
		createFace(RIGHT, x, y, z)
	if checkAir(x, y, z - 1):
		createFace(BACK, x, y, z)
	if checkAir(x, y, z + 1):
		createFace(FRONT, x, y, z)

func createFace(face, x, y, z):
	var offset = Vector3(x, y, z)
	var a = vertices[face[0]] + offset
	var b = vertices[face[1]] + offset
	var c = vertices[face[2]] + offset
	var d = vertices[face[3]] + offset
	
	
	
	
	st.add_triangle_fan(([a, b, c]))
	st.add_triangle_fan(([a, c, d]))
	

func spawnObject(objectPath, parent, x,z):
	var offset = 1
	if parent == null:
		parent = self
	
	var spawnHeight
	for y in range (0, DIMENSION.y):
		if blocks[x][y][z] == GRASS:
			spawnHeight = y
	
	var objectNew = load(objectPath).instance()
	if objectNew.is_in_group("plant"):
		objectNew.energyMax= get_parent().getRandom(plantEnergyMax)
		objectNew.energyMin= get_parent().getRandom(plantEnergyMin)
	parent.add_child(objectNew)
	
	if objectNew.is_in_group("rabbit"):
		offset = offset + 5
	
	var newLoc = Vector3(x, spawnHeight + offset, z)
	
	objectNew.global_transform.origin = newLoc
	
	return objectNew
	
	##objectNew.global_transform.origin.y = objectNew.global_transform.origin.y + 7


func _on_Timer_timeout():
	spawnObject("res://plant.tscn", self, floor(rand_range(0,DIMENSION.x)),floor(rand_range(0,DIMENSION.z)))
