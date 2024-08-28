extends Area2D

@onready var Enemy_1 = load("res://Scenes/goblin_enemy.tscn")
@onready var Enemy_2 = load("res://Scenes/barrel_enemy.tscn")
@export var navigation_region_path: NodePath

@export var living_enemies: int
@export var wait_spawn = 3
@export var enemy_variants: int
@export var probability = 30
var spawned = 0

var ready_start = false

var timers = []

func _ready() -> void:
	for i in range(living_enemies):
		var timer = Timer.new()
		timer.wait_time = (i + 2)
		timer.one_shot = true
		add_child(timer)
		timers.append({ "timer": timer, "remaining_time": timer.wait_time })
		timer.start()
		timer.connect("timeout", Callable(self, "First_Spawn").bind(i+1))


func _process(_delta: float) -> void:
	if(canSpawn() && ready_start):
		spawn()


func canSpawn():
	if (spawned < living_enemies):
		return true


func pause_spawn_timers() -> void:
	for timer_data in timers:
		var timer = timer_data["timer"]
		if not timer.is_stopped():
			timer_data["remaining_time"] = timer.time_left
			timer.stop()


func resume_spawn_timers() -> void:
	for timer_data in timers:
		var timer = timer_data["timer"]
		if timer_data["remaining_time"] > 0:
			timer.wait_time = timer_data["remaining_time"]
			timer_data["remaining_time"] = 0
			timer.start()



func First_Spawn(value):
	_clean_up_timers()
	if value == living_enemies:
		ready_start = true;
	spawn()


func _on_Enemy_died() -> void:
	var timer = Timer.new()
	timer.wait_time = wait_spawn
	timer.one_shot = true
	add_child(timer)
	timers.append({ "timer": timer, "remaining_time": timer.wait_time })  # Guardar timer y su tiempo restante
	timer.start()
	timer.connect("timeout", Callable(self, "SetSpawned"))


func SetSpawned():
	spawned -= 1
	_clean_up_timers()


func _clean_up_timers() -> void:
	var active_timers = []
	for timer_data in timers:
		if timer_data["timer"].time_left > 0:
			active_timers.append(timer_data)
	timers = active_timers


func spawn():
	var random_position = get_random_point_in_region(get_node(navigation_region_path))
	spawned += 1
	var enemi_instance
	if(enemy_variants == 1):
		enemi_instance = Enemy_1.instantiate()
	else:
		var chance = randi() % 100 + 0
		if (chance < probability):
			enemi_instance = Enemy_2.instantiate()
		else:
			enemi_instance = Enemy_1.instantiate()
	var random_number = randi() % enemy_variants + 1
	enemi_instance.connect("died", Callable(self, "_on_Enemy_died"))
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
