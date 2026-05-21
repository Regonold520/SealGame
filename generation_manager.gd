extends Node3D
class_name GenerationManager

var chunks : Dictionary = {}
@export var seed = 3
var rng = RandomNumberGenerator.new()
func  _ready() -> void:
	
	generateCaves()
	pass
	

func generateCaves():
	var rng = RandomNumberGenerator.new()
	rng.seed = seed

	var n = FastNoiseLite.new()
	var cSize = 16
	var wSize = 10
	
	var factor = 0.3 # Size of layer
	var baseHeight = 90 # Max height of layer
	var spread = 10 # Variance
	var rippleWeight = 2 # Amount of block that can be +- for surface detail
	var circles = []
	var heightMap : Dictionary[Vector2, float] = {}
	
	for i in wSize*wSize:
		var pos = Vector2(rng.randf_range(0, wSize*cSize), rng.randf_range(0, wSize*cSize))
		circles.append(pos)
		
	for cX in wSize:
		for cY in wSize:
			for x in cSize:
				for z in cSize:
					var maxDist = INF
					var chosenCirc = null
					for circ : Vector2 in circles:
						var d = circ.distance_to(Vector2(x+cX*cSize,z+cY*cSize))
						if d < maxDist:
							
							maxDist = d
							chosenCirc = circ
					
					var height = n.get_noise_2d(chosenCirc.x, chosenCirc.y)
					height = inverse_lerp(-1, 1, height)
					height *= baseHeight 
					height += n.get_noise_2d(x+cX*cSize, z+cY*cSize) * rippleWeight
					
					heightMap[Vector2(x+cX*cSize,z+cY*cSize)] = height
		
		
		
		
		
		
	for cX in wSize:
		for cY in wSize:
			for x in cSize:
				for z in cSize:
					
					var totalPos = Vector2(x+cX*cSize,z+cY*cSize)
					var heights : PackedFloat64Array = []
					var sum = 0.0
					var idk = 2
					for i in idk:
						for f in idk:
							var offset = Vector2(i - 1, f - 1)
							var pos = totalPos + offset
							if heightMap.has(pos):
								heights.append(heightMap[pos])
								sum += heightMap[pos]
					
					var height = sum / heights.size()
					
					if totalPos.distance_to(Vector2(100,100)) <= 12:
						height = heightMap[Vector2(100,100)]
						var pos = get_global_tile_pos(cX-(wSize/2), cY-(wSize/2), x, int(height) + 3, z)
					
					
					for y in 64:
						
						
						
						
						
						
						if y <= height:
							setBlock(cX-(wSize/2), cY-(wSize/2), Vector3i(x,y + 64,z), "stone")
						else:
							setBlock(cX-(wSize/2), cY-(wSize/2), Vector3i(x,y + 64,z), "air")
					var roofNoise = n.get_noise_2d((x + cX * 16)* 0.8, ( z + cY * 16)* 0.8) * 5
					setBlock(cX-(wSize/2), cY-(wSize/2), Vector3i(x,0 + 64 + round(abs(roofNoise)),z), "stone")
					setBlock(cX-(wSize/2), cY-(wSize/2), Vector3i(x,63 + 64 - round(abs(roofNoise)),z), "stone")
			buildChunkMesh(chunks[Vector2i(cX-(wSize/2),cY-(wSize/2))])
	var centerChunkX = floori(100.0 / 16.0) - (wSize / 2)
	var centerChunkY = floori(100.0 / 16.0) - (wSize / 2)

	var localX = 100 % 16
	var localZ = 100 % 16

	var centerPos = get_global_tile_pos(
		centerChunkX,
		centerChunkY,
		localX,
		int(heightMap[Vector2(100,100)]) + 2,
		localZ
	)
	
	get_tree().current_scene.find_child("StartMover").global_position = centerPos - Vector3(0,0.5,0)
	
func generateChunk(x, y):
	var chunk = {}
	chunk["mi"] = MeshInstance3D.new()
	add_child(chunk["mi"])
	chunk["mi"].position = Vector3(x * 16, 0, y * 16)
	
	chunk["blocks"] = []
	chunk["pos"] = Vector2i(x,y)
	
	for nX in 16:
		chunk["blocks"].append([])
		for nY in 128:
			chunk["blocks"][nX].append([])
			for nZ in 16:
				chunk["blocks"][nX][nY].append(Ref.blockLookup["air"])
	
	chunks[Vector2i(x,y)] = chunk

func setBlock(chunkX, chunkY, newPos, newType):
	if not chunks.has(Vector2i(chunkX, chunkY)):
		generateChunk(chunkX, chunkY)
	
	chunks[Vector2i(chunkX,chunkY)]["blocks"][newPos.x][newPos.y][newPos.z] = Ref.blockLookup[newType]
	

var faces = {
	"top": [
		Vector3(0,1,0),
		Vector3(1,1,0),
		Vector3(1,1,1),

		Vector3(0,1,0),
		Vector3(1,1,1),
		Vector3(0,1,1)
	],

	"bottom": [
		Vector3(0,0,0),
		Vector3(0,0,1),
		Vector3(1,0,1),
		Vector3(0,0,0),
		Vector3(1,0,1),
		Vector3(1,0,0)

		
	],

	"left": [
		Vector3(0,0,0),
		Vector3(0,1,0),
		Vector3(0,1,1),

		Vector3(0,0,0),
		Vector3(0,1,1),
		Vector3(0,0,1)
	],

	"right": [
		Vector3(1,0,0),
		Vector3(1,0,1),
		Vector3(1,1,1),

		Vector3(1,0,0),
		Vector3(1,1,1),
		Vector3(1,1,0)
	],

	"front": [
		Vector3(0,0,1),
		Vector3(0,1,1),
		Vector3(1,1,1),

		Vector3(0,0,1),
		Vector3(1,1,1),
		Vector3(1,0,1)
	],

	"back": [
		Vector3(0,0,0),
		Vector3(1,0,0),
		Vector3(1,1,0),
		Vector3(0,0,0),
		Vector3(1,1,0),
		Vector3(0,1,0)

		
	]
}

func get_global_tile_pos(chunkX:int, chunkY:int, tileX:int, tileY:int, tileZ:int) -> Vector3:
	return Vector3(
		chunkX * 16 + tileX,
		tileY,
		chunkY * 16 + tileZ
	)

func global_to_tile(global_pos: Vector3) -> Dictionary:
	var chunk_x = floori(global_pos.x / 16.0)
	var chunk_y = floori(global_pos.z / 16.0)

	var tile_x = posmod(floori(global_pos.x), 16)
	var tile_z = posmod(floori(global_pos.z), 16)

	var tile_y = floori(global_pos.y) + 64

	return {
		"chunkX": chunk_x,
		"chunkY": chunk_y,
		"tileX": tile_x,
		"tileY": tile_y,
		"tileZ": tile_z
	}

func buildChunkMesh(chunk):
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for x in 16:
		for y in 128:
			for z in 16:
				var block = chunk["blocks"][x][y][z]
				if block == 0:
					continue
				else:
					if isAir(chunk,x,y+1,z):
						renderFace(st, Vector3(x,y- 64,z), "top", block)
					if isAir(chunk,x,y-1,z):
						renderFace(st, Vector3(x,y- 64,z), "bottom", block)
					if isAir(chunk,x+1,y,z):
						renderFace(st, Vector3(x,y- 64,z), "right", block)
					if isAir(chunk,x-1,y,z):
						renderFace(st, Vector3(x,y- 64,z), "left", block)
					if isAir(chunk,x,y,z+1):
						renderFace(st, Vector3(x,y- 64,z), "front", block)
					if isAir(chunk,x,y,z-1):
						renderFace(st, Vector3(x,y- 64,z), "back", block)
						
	st.generate_normals()
	var mesh = st.commit()
	var mat = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	mat.diffuse_mode = BaseMaterial3D.DIFFUSE_LAMBERT
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	
	mat.albedo_texture = preload("res://atlas.png")
	
	mesh.surface_set_material(0, mat)

	
	
	chunk["mi"].mesh = mesh
	chunk["mi"].create_trimesh_collision()
	
func renderFace(st, pos, dir, blockId):
	var f = faces[dir]
	st.set_smooth_group(-1)

	st.set_uv(get_uv(Vector2(0,0), blockId))
	st.add_vertex(pos + f[0])

	st.set_uv(get_uv(Vector2(1,0), blockId))
	st.add_vertex(pos + f[1])

	st.set_uv(get_uv(Vector2(1,1), blockId))
	st.add_vertex(pos + f[2])

	st.set_uv(get_uv(Vector2(0,0), blockId))
	st.add_vertex(pos + f[3])

	st.set_uv(get_uv(Vector2(1,1), blockId))
	st.add_vertex(pos + f[4])

	st.set_uv(get_uv(Vector2(0,1), blockId))
	st.add_vertex(pos + f[5])

func get_uv(localUV: Vector2, blockId):
	var tileSize = 1.0 / 2

	var tileX = blockId - 1

	return Vector2(
		(tileX + localUV.x) * tileSize,
		localUV.y
	)

func isAir(chunk, x, y, z):
	var chunkPos = chunk["pos"]

	if y < 0 or y >= 128:
		return true

	if x < 0:
		return getBlock(chunkPos.x - 1, chunkPos.y, 15, y, z) == 0

	if x >= 16:
		return getBlock(chunkPos.x + 1, chunkPos.y, 0, y, z) == 0

	if z < 0:
		return getBlock(chunkPos.x, chunkPos.y - 1, x, y, 15) == 0

	if z >= 16:
		return getBlock(chunkPos.x, chunkPos.y + 1, x, y, 0) == 0

	return chunk["blocks"][x][y][z] == 0

func getBlock(chunkX, chunkY, x, y, z):
	
	if !chunks.has(Vector2i(chunkX, chunkY)):
		return 0
	return chunks[Vector2i(chunkX, chunkY)]["blocks"][x][y][z]
