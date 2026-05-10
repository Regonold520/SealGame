extends Node3D
class_name GenerationManager

var chunks : Dictionary = {}
@export var seed = 1
var rng = RandomNumberGenerator.new()
func  _ready() -> void:
	for cX in 10:
		for cY in 10:
			for x in 16:
				for z in 16:
					for y in 128:
						var pick = "stone"
						if rng.randi_range(0,1) == 0: pick = "stone2"
						setBlock(cX, cY, Vector3i(x,y,z), pick)
			await get_tree().create_timer(0.001).timeout
			buildChunkMesh(chunks[Vector2i(cX,cY)])
			


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
		Vector3(1,0,1),
		Vector3(1,0,0),

		Vector3(0,0,0),
		Vector3(0,0,1),
		Vector3(1,0,1)
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

func isAir(chunk,x,y,z):
	if x < 0 or x >= 16 or y < 0 or y >= 128 or z < 0 or z >= 16:
		return true
	return chunk["blocks"][x][y][z] == 0
