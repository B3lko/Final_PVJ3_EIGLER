extends Area2D

@onready var Enemy_1 = load("res://Scenes/goblin_enemy.tscn")
@export var navigation_region_path: NodePath

@export var living_enemies = 5
@export var wait_spawn = 5
var spawned = 0

func _process(delta: float) -> void:
	if(canSpawn()):
		spawn()
	

func canSpawn():
	if (spawned < living_enemies):
		return true

func spawn():
	var random_position = get_random_point_in_region(get_node(navigation_region_path))
	spawned += 1
	var enemi_instance = Enemy_1.instantiate()
	enemi_instance.position = random_position
	add_child(enemi_instance)


func get_random_point_in_region(region: NavigationRegion2D) -> Vector2:
	var nav_polygon: NavigationPolygon = region.get_navigation_polygon()
	if nav_polygon.get_polygon_count() == 0:
		return Vector2.ZERO
	var vertices: PackedVector2Array = nav_polygon.get_vertices()
	var triangles = []
	
	for i in range(nav_polygon.get_polygon_count()):
		var polygon: PackedInt32Array = nav_polygon.get_polygon(i)
		for j in range(2, polygon.size()):
			var index1 = polygon[0]
			var index2 = polygon[j - 1]
			var index3 = polygon[j]
			triangles.append([index1, index2, index3])

	var random_triangle = triangles[randi() % triangles.size()]

	var p1: Vector2 = vertices[random_triangle[0]]
	var p2: Vector2 = vertices[random_triangle[1]]
	var p3: Vector2 = vertices[random_triangle[2]]

	var r1 = randf()
	var r2 = randf()

	if r1 + r2 > 1.0:
		r1 = 1.0 - r1
		r2 = 1.0 - r2

	var v1: Vector2 = (p2 - p1) * r1
	var v2: Vector2 = (p3 - p1) * r2
	var random_point: Vector2 = p1 + v1 + v2

	return random_point
