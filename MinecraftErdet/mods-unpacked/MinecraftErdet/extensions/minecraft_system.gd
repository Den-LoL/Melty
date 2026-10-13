extends Node

const MOD_ID := "Melty-MinecraftErdet"

var blocks_data := {}
var items_data := {}
var recipes_data := {}
var player_inventory := {}
var hotbar_slots := 9
var selected_hotbar_slot := 0
var crafting_open := false
var inventory_open := false

var block_scenes := {}
var item_textures := {}
var block_colors := {
	"stone": Color(0.5, 0.5, 0.5),
	"cobblestone": Color(0.4, 0.4, 0.4),
	"dirt": Color(0.6, 0.4, 0.2),
	"grass_block": Color(0.3, 0.6, 0.2),
	"oak_log": Color(0.4, 0.3, 0.2),
	"oak_planks": Color(0.6, 0.5, 0.3),
	"sand": Color(0.9, 0.85, 0.6),
	"glass": Color(0.8, 0.9, 1.0),
	"coal_ore": Color(0.35, 0.35, 0.35),
	"iron_ore": Color(0.6, 0.5, 0.4),
	"gold_ore": Color(0.7, 0.65, 0.3),
	"diamond_ore": Color(0.4, 0.7, 0.7),
	"crafting_table": Color(0.5, 0.35, 0.2),
	"furnace": Color(0.4, 0.4, 0.45),
	"chest": Color(0.6, 0.4, 0.2),
	"iron_block": Color(0.8, 0.8, 0.85),
	"gold_block": Color(0.9, 0.8, 0.2),
	"diamond_block": Color(0.4, 0.8, 0.8),
	"obsidian": Color(0.15, 0.1, 0.2),
	"redstone_ore": Color(0.5, 0.2, 0.2)
}

var item_colors := {
	"stick": Color(0.6, 0.5, 0.3),
	"coal": Color(0.2, 0.2, 0.2),
	"raw_iron": Color(0.7, 0.6, 0.5),
	"iron_ingot": Color(0.8, 0.8, 0.85),
	"raw_gold": Color(0.9, 0.8, 0.4),
	"gold_ingot": Color(0.95, 0.85, 0.3),
	"diamond": Color(0.3, 0.8, 0.9),
	"redstone": Color(0.8, 0.1, 0.1),
	"wooden_pickaxe": Color(0.6, 0.5, 0.3),
	"stone_pickaxe": Color(0.5, 0.5, 0.5),
	"iron_pickaxe": Color(0.8, 0.8, 0.85),
	"gold_pickaxe": Color(0.95, 0.85, 0.3),
	"diamond_pickaxe": Color(0.3, 0.8, 0.9),
	"wooden_axe": Color(0.6, 0.5, 0.3),
	"stone_axe": Color(0.5, 0.5, 0.5),
	"iron_axe": Color(0.8, 0.8, 0.85),
	"gold_axe": Color(0.95, 0.85, 0.3),
	"diamond_axe": Color(0.3, 0.8, 0.9),
	"wooden_shovel": Color(0.6, 0.5, 0.3),
	"stone_shovel": Color(0.5, 0.5, 0.5),
	"iron_shovel": Color(0.8, 0.8, 0.85),
	"gold_shovel": Color(0.95, 0.85, 0.3),
	"diamond_shovel": Color(0.3, 0.8, 0.9),
	"wooden_sword": Color(0.6, 0.5, 0.3),
	"stone_sword": Color(0.5, 0.5, 0.5),
	"iron_sword": Color(0.8, 0.8, 0.85),
	"gold_sword": Color(0.95, 0.85, 0.3),
	"diamond_sword": Color(0.3, 0.8, 0.9),
	"leather_helmet": Color(0.6, 0.4, 0.2),
	"iron_helmet": Color(0.8, 0.8, 0.85),
	"diamond_helmet": Color(0.3, 0.8, 0.9),
	"leather_chestplate": Color(0.6, 0.4, 0.2),
	"iron_chestplate": Color(0.8, 0.8, 0.85),
	"diamond_chestplate": Color(0.3, 0.8, 0.9),
	"leather_leggings": Color(0.6, 0.4, 0.2),
	"iron_leggings": Color(0.8, 0.8, 0.85),
	"diamond_leggings": Color(0.3, 0.8, 0.9),
	"leather_boots": Color(0.6, 0.4, 0.2),
	"iron_boots": Color(0.8, 0.8, 0.85),
	"diamond_boots": Color(0.3, 0.8, 0.9),
	"torch": Color(0.9, 0.7, 0.3)
}

var ui_panel: Control
var inventory_grid: GridContainer
var hotbar_bar: HBoxContainer
var crafting_grid: GridContainer
var crafting_result: TextureButton

var player_node: Node3D
var camera_node: Camera3D
var ray_cast: RayCast3D

signal inventory_changed
signal hotbar_changed

func _ready() -> void:
	print("[MinecraftErdet] Loading Minecraft system...")
	load_data()
	setup_ui()
	setup_input_hooks()
	print("[MinecraftErdet] Minecraft system loaded!")

func load_data() -> void:
	var mod_dir := ModLoaderMod.get_unpacked_dir().path_join(MOD_ID)

	var blocks_file := FileAccess.open(mod_dir.path_join("blocks.json"), FileAccess.READ)
	if blocks_file:
		var json_text := blocks_file.get_as_text()
		blocks_file.close()
		var json := JSON.new()
		var error := json.parse(json_text)
		if error == OK:
			blocks_data = json.data["blocks"]
			print("[MinecraftErdet] Loaded ", blocks_data.size(), " blocks")
		else:
			print("[MinecraftErdet] Error parsing blocks.json: ", json.get_error_message())

	var items_file := FileAccess.open(mod_dir.path_join("items.json"), FileAccess.READ)
	if items_file:
		var json_text := items_file.get_as_text()
		items_file.close()
		var json := JSON.new()
		var error := json.parse(json_text)
		if error == OK:
			items_data = json.data["items"]
			print("[MinecraftErdet] Loaded ", items_data.size(), " items")
		else:
			print("[MinecraftErdet] Error parsing items.json: ", json.get_error_message())

	var recipes_file := FileAccess.open(mod_dir.path_join("recipes.json"), FileAccess.READ)
	if recipes_file:
		var json_text := recipes_file.get_as_text()
		recipes_file.close()
		var json := JSON.new()
		var error := json.parse(json_text)
		if error == OK:
			recipes_data = json.data["recipes"]
			print("[MinecraftErdet] Loaded ", recipes_data.size(), " recipes")
		else:
			print("[MinecraftErdet] Error parsing recipes.json: ", json.get_error_message())

	initialize_starter_inventory()

func initialize_starter_inventory() -> void:
	for i in range(hotbar_slots):
		player_inventory[i] = null

	player_inventory[0] = {"id": "wooden_pickaxe", "count": 1}
	player_inventory[1] = {"id": "wooden_axe", "count": 1}
	player_inventory[2] = {"id": "oak_planks", "count": 64}
	player_inventory[3] = {"id": "cobblestone", "count": 64}
	player_inventory[4] = {"id": "torch", "count": 64}

	inventory_changed.emit()
	hotbar_changed.emit()

func setup_ui() -> void:
	ui_panel = Control.new()
	ui_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui_panel.z_index = 1000

	var hotbar_container := HBoxContainer.new()
	hotbar_container.position = Vector2(0, 0)
	hotbar_container.size = Vector2(400, 50)
	hotbar_container.position = Vector2(
		(get_viewport().size.x - 400) / 2,
		get_viewport().size.y - 60
	)

	for i in range(hotbar_slots):
		var slot := TextureRect.new()
		slot.custom_minimum_size = Vector2(40, 40)
		slot.modulate = Color(0.5, 0.5, 0.5, 0.8)
		if i == selected_hotbar_slot:
			slot.modulate = Color(1.0, 1.0, 1.0, 1.0)
		slot.name = "hotbar_" + str(i)
		hotbar_container.add_child(slot)

	hotbar_bar = hotbar_container
	ui_panel.add_child(hotbar_container)

	get_tree().root.add_child(ui_panel)
	ui_panel.hide()

	update_hotbar_ui()

func update_hotbar_ui() -> void:
	if not hotbar_bar:
		return

	for i in range(hotbar_slots):
		var slot := hotbar_bar.get_node("hotbar_" + str(i))
		if slot:
			slot.texture = null
			if player_inventory.has(i) and player_inventory[i]:
				var item_data = get_item_data(player_inventory[i].id)
				if item_data:
					var item_color = item_colors.get(player_inventory[i].id, Color.WHITE)
					slot.modulate = item_color
					slot.color = item_color
				else:
					slot.modulate = Color(0.5, 0.5, 0.5, 0.8)
			else:
				slot.modulate = Color(0.3, 0.3, 0.3, 0.5)

			if i == selected_hotbar_slot:
				slot.modulate = slot.modulate * Color(1.5, 1.5, 1.5, 1.0)

func setup_input_hooks() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_E:
			toggle_inventory()
		elif event.keycode == KEY_1:
			select_hotbar_slot(0)
		elif event.keycode == KEY_2:
			select_hotbar_slot(1)
		elif event.keycode == KEY_3:
			select_hotbar_slot(2)
		elif event.keycode == KEY_4:
			select_hotbar_slot(3)
		elif event.keycode == KEY_5:
			select_hotbar_slot(4)
		elif event.keycode == KEY_6:
			select_hotbar_slot(5)
		elif event.keycode == KEY_7:
			select_hotbar_slot(6)
		elif event.keycode == KEY_8:
			select_hotbar_slot(7)
		elif event.keycode == KEY_9:
			select_hotbar_slot(8)

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not inventory_open and not crafting_open:
				on_left_click()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			if not inventory_open and not crafting_open:
				on_right_click()

func toggle_inventory() -> void:
	inventory_open = not inventory_open
	if inventory_open:
		ui_panel.show()
		hotbar_bar.show()
	else:
		ui_panel.hide()

func select_hotbar_slot(slot: int) -> void:
	if slot >= 0 and slot < hotbar_slots:
		selected_hotbar_slot = slot
		hotbar_changed.emit()
		update_hotbar_ui()

func get_item_data(item_id: String) -> Dictionary:
	for item in items_data:
		if item.id == item_id:
			return item
	return {}

func get_block_data(block_id: String) -> Dictionary:
	for block in blocks_data:
		if block.id == block_id:
			return block
	return {}

func on_left_click() -> void:
	if not player_node or not ray_cast:
		find_player_and_camera()
		if not player_node or not ray_cast:
			return

	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var collider := ray_cast.get_collider()
		if collider and collider.has_method("on_mined"):
			collider.on_mined(player_node)

func on_right_click() -> void:
	if not player_node or not ray_cast:
		find_player_and_camera()
		if not player_node or not ray_cast:
			return

	var held_item = player_inventory.get(selected_hotbar_slot)
	if not held_item:
		return

	var item_data = get_item_data(held_item.id)
	if not item_data:
		return

	if item_data.is_tool:
		return

	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		var point := ray_cast.get_collision_point()
		var normal := ray_cast.get_collision_normal()
		place_block(point + normal * 0.5, held_item.id)

func place_block(position: Vector3, block_id: String) -> void:
	var block_data = get_block_data(block_id)
	if not block_data:
		return

	var block := MeshInstance3D.new()
	block.position = position

	var box_mesh := BoxMesh.new()
	box_mesh.size = Vector3(1, 1, 1)
	block.mesh = box_mesh

	var block_color = block_colors.get(block_id, Color(0.5, 0.5, 0.5))
	var material := StandardMaterial3D.new()
	material.albedo_color = block_color
	block.material_override = material

	block.set_meta("block_id", block_id)
	block.set_meta("is_minecraft_block", true)

	get_tree().current_scene.add_child(block)

func find_player_and_camera() -> void:
	if player_node and camera_node:
		return

	var root := get_tree().current_scene
	if not root:
		return

	for child in root.get_children():
		if child is CharacterBody3D or child is RigidBody3D:
			player_node = child
			for subchild in child.get_children():
				if subchild is Camera3D:
					camera_node = subchild
					ray_cast = RayCast3D.new()
					ray_cast.target_position = Vector3(0, 0, -5)
					camera_node.add_child(ray_cast)
					ray_cast.enabled = true
					break
			break

func _process(_delta: float) -> void:
	if not ui_panel.visible and not inventory_open:
		ui_panel.hide()
		hotbar_bar.hide()
	elif ui_panel.visible:
		hotbar_bar.show()
