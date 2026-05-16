extends Node3D
class_name GenerationManager

var chunks : Dictionary = {}
@export var seed = 1
var rng = RandomNumberGenerator.new()
func  _ready() -> void:
	
	generateCaves()
	pass
	

func generateCaves():
	var n = FastNoiseLite.new()
	var cSize = 10
	var factor = 0.5
	var baseHeight = 20
	for cX in cSize:
		for cY in cSize:
			for x in 16:
				for z in 16:
					var sX = round((x+cX*cSize) * factor) * (1 / factor)
					var sZ = round((z+cY*cSize) * factor) * (1 / factor)
					
					var height = n.get_noise_2d(sX, sZ)
					height = inverse_lerp(-1, 1, height)
					height *= baseHeight 
					print(height)
					
					for y in 64:
						
						
						
						
						
						
						if y <= height:
							setBlock(cX-(cSize/2), cY-(cSize/2), Vector3i(x,y + 64,z), "stone")
						else:
							setBlock(cX-(cSize/2), cY-(cSize/2), Vector3i(x,y + 64,z), "air")
					var roofNoise = n.get_noise_2d((x + cX * 16)* 0.8, ( z + cY * 16)* 0.8) * 5
					setBlock(cX-(cSize/2), cY-(cSize/2), Vector3i(x,0 + 64 + round(abs(roofNoise)),z), "stone")
					setBlock(cX-(cSize/2), cY-(cSize/2), Vector3i(x,63 + 64 - round(abs(roofNoise)),z), "stone")
			await get_tree().create_timer(0.001).timeout
			buildChunkMesh(chunks[Vector2i(cX-(cSize/2),cY-(cSize/2))])

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
