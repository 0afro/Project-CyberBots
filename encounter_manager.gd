extends Node

var current_area := 1
var total_areas := 5
var areas := []
var objective_marker: MeshInstance3D = null
var hud = null
var area_transitioning := false  # Prevents repeated calls during area transition
var victory_scene = preload("res://victory_screen.tscn")  # Victory screen scene

func _ready():
	add_to_group("encounter_manager")
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Try to get markers - using get_node_or_null for safety
	print("=== SEARCHING FOR MARKERS ===")
	
	var area_1_marker = get_node_or_null("../area_1/Marker")
	var area_2_marker = get_node_or_null("../area_2/Marker")
	var area_3_marker = get_node_or_null("../area_3/Marker")
	var area_4_marker = get_node_or_null("../area_4/Marker")
	var area_5_marker = get_node_or_null("../area_5/Marker")
	
	# Debug each marker
	print("Area 1 marker: ", area_1_marker)
	print("Area 2 marker: ", area_2_marker)
	print("Area 3 marker: ", area_3_marker)
	print("Area 4 marker: ", area_4_marker)
	print("Area 5 marker: ", area_5_marker)
	
	# Check if any failed
	if not area_1_marker:
		print("ERROR: Could not find area_1/Marker - check scene structure!")
		return
	
	# Build areas array ONLY if markers found
	areas = [
		{"name": "area_1", "marker": area_1_marker},
		{"name": "area_2", "marker": area_2_marker},
		{"name": "area_3", "marker": area_3_marker},
		{"name": "area_4", "marker": area_4_marker},
		{"name": "area_5", "marker": area_5_marker}
	]
	
	print("Areas array built with ", areas.size(), " entries")
	
	create_objective_marker()
	hud = get_tree().get_first_node_in_group("hud")
	
	await get_tree().process_frame
	update_objective()
	
	print("Encounter Manager initialized!")

func _process(_delta):
	# Safety check - make sure areas array exists
	if areas.size() == 0:
		return
	
	# Skip if already transitioning between areas or game is over
	if area_transitioning:
		return
	
	if is_area_cleared(current_area):
		area_cleared()

func is_area_cleared(area_number: int) -> bool:
	# Safety check
	if areas.size() == 0 or area_number < 1 or area_number > areas.size():
		return false
	
	var group_name = areas[area_number - 1]["name"]
	var enemies = get_tree().get_nodes_in_group(group_name)
	return enemies.size() == 0

func area_cleared():
	print("=== AREA ", current_area, " CLEARED! ===")
	area_transitioning = true  # Lock to prevent repeated calls
	current_area += 1
	
	if current_area > total_areas:
		victory()
	else:
		await get_tree().create_timer(2.0).timeout
		update_objective()
		print("NEW OBJECTIVE: Clear Area ", current_area)
		area_transitioning = false  # Unlock after transition

func update_objective():
	if current_area <= total_areas and areas.size() > 0:
		var marker = areas[current_area - 1]["marker"]
		
		if marker and objective_marker:
			var target_pos = marker.global_position
			target_pos.y += 50.0
			
			objective_marker.global_position = target_pos
			objective_marker.visible = true
			
			print("Beacon at Area ", current_area, " - Position: ", target_pos)
		else:
			print("ERROR: Marker or beacon is null!")
		
		if hud and hud.has_method("update_objective"):
			hud.update_objective(current_area, total_areas)

func create_objective_marker():
	objective_marker = MeshInstance3D.new()
	add_child(objective_marker)
	
	# Arrow pointing down
	var mesh = CylinderMesh.new()
	mesh.height = 50.0
	mesh.top_radius = 8.0  # Wide at top
	mesh.bottom_radius = 0.0  # Point at bottom
	objective_marker.mesh = mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.02, 0.282, 0.918, 0.698)
	material.emission_enabled = true
	material.emission = Color(0.02, 0.282, 0.918, 0.698)
	material.emission_energy_multiplier = 10.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	objective_marker.set_surface_override_material(0, material)
	
	print("Downward arrow beacon created")

func victory():
	print("=== VICTORY! ===")
	area_transitioning = true  # Stay locked, game is over
	
	if objective_marker:
		objective_marker.visible = false
	
	# Show victory screen instead of reloading
	var victory_screen = victory_scene.instantiate()
	get_tree().root.add_child(victory_screen)
