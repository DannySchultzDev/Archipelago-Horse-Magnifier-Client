local utils = require("gdpatch.utils")

GDPatch.patch_project_settings(function(settings)
	table.insert(settings, 1, {
		"autoload/Archipelago",
		"*res://godot_ap/autoloads/archipelago.tscn"
	})
	return settings
end)

GDPatch.patch_script_as_text("scenes/ui/main_menu/main_menu.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[class_name MainMenu]]),
		utils.escape(
[[class_name MainMenu

var main_menu_controls: Dictionary
var main_menu_unlocks: Dictionary

func _process(delta: float) -> void:
	if Archipelago.is_ap_connected():
		if int(Archipelago.conn.slot_data["deathlink"]) != 0:
			if not Archipelago.AP_GAME_TAGS.has("DeathLink"):
				Archipelago.AP_GAME_TAGS.append("DeathLink")
				Archipelago._update_tags()
		else:
			if Archipelago.AP_GAME_TAGS.has("DeathLink"):
				Archipelago.AP_GAME_TAGS.erase("DeathLink")
				Archipelago._update_tags()

		for unlock in main_menu_unlocks:
			main_menu_unlocks[unlock].visible = true
			if unlock == "Items Panel":
				continue
			
			elif unlock == "Horse Count":
				var should_boot = true
				var horse_count = 0
				var horse_total = 40
				var horse_req = 100
				horse_total = Archipelago.conn.slot_data["horse_amount"]
				horse_req = Archipelago.conn.slot_data["goal_requirement"]
				for item in Archipelago.conn.received_items:
					if item.get_name() == "Horse":
						horse_count += 1
				
				var true_horse_req: int = int((horse_req / 100.0) * horse_total)
			
				if horse_count < true_horse_req:
					main_menu_unlocks[unlock].add_theme_color_override("font_color", Color.RED)
				else:
					main_menu_unlocks[unlock].add_theme_color_override("font_color", Color.GREEN)
				
				main_menu_unlocks[unlock].text = "Horses: " + str(horse_count) + "/" + str(true_horse_req)
				
				continue
			
			
			main_menu_unlocks[unlock].add_theme_color_override("font_color", Color.RED)
			
			for item in Archipelago.conn.received_items:
				if item.get_name() == unlock:
					main_menu_unlocks[unlock].add_theme_color_override("font_color", Color.GREEN)
	else:
		for unlock in main_menu_unlocks:
			main_menu_unlocks[unlock].visible = false

func try_connect() -> void:
	print("Trying to connect")
	Archipelago.AP_GAME_NAME = "Horse Magnifier"
	var connection_ip: String
	var connection_port: String
	if main_menu_controls["Connection Textbox"].text == "localhost":
		connection_ip = "localhost"
		connection_port = "38281"
	else:
		var connection_split = main_menu_controls["Connection Textbox"].text.split(':')
		if connection_split.size() < 2:
			print("Could not connect since connection field was not filled out.")
			return
		connection_ip = connection_split[0]
		connection_port = connection_split[1]
	
	Archipelago.ap_connect(connection_ip, connection_port, main_menu_controls["Slot Name Textbox"].text, main_menu_controls["Password Textbox"].text)
	
	var folder_path := OS.get_user_data_dir().path_join("ArchipelagoHorseMagnifierClient")
	var file_path := folder_path.path_join("Connection Info.txt")
	var dir := DirAccess.open(OS.get_user_data_dir())
	if dir == null:
		print("Could not save connection info since the client could not find the User folder.")
		return
	
	var err := dir.make_dir_recursive("ArchipelagoHorseMagnifierClient")
	if err != OK and err != ERR_ALREADY_EXISTS:
		print("Could not save connection info since the client could not create the User folder.")
		return
	
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("Could not save connection info since the client could not open or create the connection info file.")
		return
	
	file.store_string(connection_ip + "\n" + connection_port + "\n" +
	main_menu_controls["Slot Name Textbox"].text + "\n" + main_menu_controls["Password Textbox"].text)]], true)
	)
end)

GDPatch.patch_script_as_text("scenes/ui/main_menu/main_menu.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func _ready() -> void :]]),
		utils.escape(
[[func _ready() -> void :
	print("Checking saved connection settings")

	var folder_path := OS.get_user_data_dir().path_join("ArchipelagoHorseMagnifierClient")
	var file_path := folder_path.path_join("Connection Info.txt")
	var connection_saved
	var connection_saved_valid: bool = false
	if FileAccess.file_exists(file_path):
		var file := FileAccess.open(file_path, FileAccess.READ)
		if file != null:
			connection_saved = file.get_as_text().split("\n")
			connection_saved_valid = connection_saved.size() == 4
			file.close()

	if connection_saved_valid:
		print("Connection: " + connection_saved[0])
		print("Port: " + connection_saved[1])
		print("Slot Name: " + connection_saved[2])
		print("Password: " + connection_saved[3])

	print("Adjusting the main menu")

	var connection_label = Label.new()
	connection_label.position = Vector2(50, 20)
	connection_label.size = Vector2(500, 50)
	connection_label.add_theme_color_override("font_color", Color.BLACK)
	connection_label.text = "Connection: "
	add_child(connection_label)
	main_menu_controls["Connection Label"] = connection_label

	var connection_textbox = LineEdit.new()
	connection_textbox.position = Vector2(350, 20)
	connection_textbox.size = Vector2(500, 50)
	connection_textbox.placeholder_text = "archipelago.gg:12345"
	connection_textbox.text = ""
	if connection_saved_valid:
		connection_textbox.text = connection_saved[0] + ":" + connection_saved[1]
	add_child(connection_textbox)
	main_menu_controls["Connection Textbox"] = connection_textbox

	var slot_name_label = Label.new()
	slot_name_label.position = Vector2(50, 80)
	slot_name_label.size = Vector2(500, 50)
	slot_name_label.add_theme_color_override("font_color", Color.BLACK)
	slot_name_label.text = "Slot Name: "
	add_child(slot_name_label)
	main_menu_controls["Slot Name Label"] = slot_name_label

	var slot_name_textbox = LineEdit.new()
	slot_name_textbox.position = Vector2(350, 80)
	slot_name_textbox.size = Vector2(500, 50)
	slot_name_textbox.placeholder_text = "Horseplayer"
	slot_name_textbox.text = ""
	if connection_saved_valid:
		slot_name_textbox.text = connection_saved[2]
	add_child(slot_name_textbox)
	main_menu_controls["Slot Name Textbox"] = slot_name_textbox

	var password_label = Label.new()
	password_label.position = Vector2(50, 140)
	password_label.size = Vector2(500, 50)
	password_label.add_theme_color_override("font_color", Color.BLACK)
	password_label.text = "Password: "
	add_child(password_label)
	main_menu_controls["Password Label"] = password_label

	var password_textbox = LineEdit.new()
	password_textbox.position = Vector2(350, 140)
	password_textbox.size = Vector2(500, 50)
	password_textbox.placeholder_text = "leave blank if none"
	password_textbox.text = ""
	if connection_saved_valid:
		password_textbox.text = connection_saved[3]
	add_child(password_textbox)
	main_menu_controls["Password Textbox"] = password_textbox

	var connect_button = Button.new()
	connect_button.position = Vector2(900, 20)
	connect_button.size = Vector2(200, 50)
	connect_button.text = "Connect"
	add_child(connect_button)
	connect_button.pressed.connect(try_connect)
	main_menu_controls["Connect Button"] = connect_button

	var items_panel = Panel.new()
	items_panel.position = Vector2(30, 280)
	items_panel.size = Vector2(750, 450)
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.25, 0.25, 0.75)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	items_panel.add_theme_stylebox_override("panel", style)
	add_child(items_panel)
	main_menu_controls["Items Panel"] = items_panel
	main_menu_unlocks["Items Panel"] = items_panel
	
	var fisheye_label = Label.new()
	fisheye_label.position = Vector2(50, 300)
	fisheye_label.size = Vector2(500, 50)
	fisheye_label.add_theme_color_override("font_color", Color.RED)
	fisheye_label.text = "Fisheye Lens"
	add_child(fisheye_label)
	main_menu_controls["Fisheye Lens"] = fisheye_label
	main_menu_unlocks["Fisheye Lens"] = fisheye_label

	var anti_fisheye_label = Label.new()
	anti_fisheye_label.position = Vector2(400, 300)
	anti_fisheye_label.size = Vector2(500, 50)
	anti_fisheye_label.add_theme_color_override("font_color", Color.RED)
	anti_fisheye_label.text = "Anti-Fisheye Lens"
	add_child(anti_fisheye_label)
	main_menu_controls["Anti-Fisheye Lens"] = anti_fisheye_label
	main_menu_unlocks["Anti-Fisheye Lens"] = anti_fisheye_label


	var flip_label = Label.new()
	flip_label.position = Vector2(50, 360)
	flip_label.size = Vector2(500, 50)
	flip_label.add_theme_color_override("font_color", Color.RED)
	flip_label.text = "Flip Lens"
	add_child(flip_label)
	main_menu_controls["Flip Lens"] = flip_label
	main_menu_unlocks["Flip Lens"] = flip_label
	
	var stretch_label = Label.new()
	stretch_label.position = Vector2(400, 360)
	stretch_label.size = Vector2(500, 50)
	stretch_label.add_theme_color_override("font_color", Color.RED)
	stretch_label.text = "Stretch Lens"
	add_child(stretch_label)
	main_menu_controls["Stretch Lens"] = stretch_label
	main_menu_unlocks["Stretch Lens"] = stretch_label
	
	var compress_label = Label.new()
	compress_label.position = Vector2(50, 420)
	compress_label.size = Vector2(500, 50)
	compress_label.add_theme_color_override("font_color", Color.RED)
	compress_label.text = "Compress Lens"
	add_child(compress_label)
	main_menu_controls["Compress Lens"] = compress_label
	main_menu_unlocks["Compress Lens"] = compress_label
	
	var swirl_label = Label.new()
	swirl_label.position = Vector2(400, 420)
	swirl_label.size = Vector2(500, 50)
	swirl_label.add_theme_color_override("font_color", Color.RED)
	swirl_label.text = "Swirl Lens"
	add_child(swirl_label)
	main_menu_controls["Swirl Lens"] = swirl_label
	main_menu_unlocks["Swirl Lens"] = swirl_label
	
	var portal_label = Label.new()
	portal_label.position = Vector2(50, 480)
	portal_label.size = Vector2(500, 50)
	portal_label.add_theme_color_override("font_color", Color.RED)
	portal_label.text = "Portal Lens"
	add_child(portal_label)
	main_menu_controls["Portal Lens"] = portal_label
	main_menu_unlocks["Portal Lens"] = portal_label
	
	var replicator_label = Label.new()
	replicator_label.position = Vector2(400, 480)
	replicator_label.size = Vector2(500, 50)
	replicator_label.add_theme_color_override("font_color", Color.RED)
	replicator_label.text = "Replicator Lens"
	add_child(replicator_label)
	main_menu_controls["Replicator Lens"] = replicator_label
	main_menu_unlocks["Replicator Lens"] = replicator_label
	
	var xray_label = Label.new()
	xray_label.position = Vector2(50, 540)
	xray_label.size = Vector2(500, 50)
	xray_label.add_theme_color_override("font_color", Color.RED)
	xray_label.text = "X-Ray Lens"
	add_child(xray_label)
	main_menu_controls["X-Ray Lens"] = xray_label
	main_menu_unlocks["X-Ray Lens"] = xray_label
	
	var color_label = Label.new()
	color_label.position = Vector2(400, 540)
	color_label.size = Vector2(500, 50)
	color_label.add_theme_color_override("font_color", Color.RED)
	color_label.text = "Color Lens"
	add_child(color_label)
	main_menu_controls["Color Lens"] = color_label
	main_menu_unlocks["Color Lens"] = color_label
	
	var apple_label = Label.new()
	apple_label.position = Vector2(50, 600)
	apple_label.size = Vector2(500, 50)
	apple_label.add_theme_color_override("font_color", Color.RED)
	apple_label.text = "Apple"
	add_child(apple_label)
	main_menu_controls["Apple"] = apple_label
	main_menu_unlocks["Apple"] = apple_label
	
	var swatter_label = Label.new()
	swatter_label.position = Vector2(400, 600)
	swatter_label.size = Vector2(500, 50)
	swatter_label.add_theme_color_override("font_color", Color.RED)
	swatter_label.text = "Horsefly Swatter"
	add_child(swatter_label)
	main_menu_controls["Horsefly Swatter"] = swatter_label
	main_menu_unlocks["Horsefly Swatter"] = swatter_label
	
	var horse_count_label = Label.new()
	horse_count_label.position = Vector2(50, 660)
	horse_count_label.size = Vector2(1000, 50)
	horse_count_label.add_theme_color_override("font_color", Color.RED)
	horse_count_label.text = "Horses: 0/40"
	add_child(horse_count_label)
	main_menu_controls["Horse Count"] = horse_count_label
	main_menu_unlocks["Horse Count"] = horse_count_label

	print("AP main menu updated")]], true)
	)
end)

GDPatch.patch_script_as_text("scenes/ui/main_menu/main_menu.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[=[	version_label.text = "v%s%s" % [Platform.VERSION, " (debug)" if Platform.DEBUG else ""]]=]),
		utils.escape(
[[	version_label.text = "Archipelago Horse Magnifier Client Ver 1.1.0"
	print("AP version updated")]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/components/lens.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[		if is_dragging:]]),
		utils.escape(
[[	
		# Only the player's lenses need to be modified.
		var can_toggle: bool = true
		if mode == Mode.GOAL:
			can_toggle = false
		
		if name == "AppleGoal":
			can_toggle = false
		
		if can_toggle:
			var has_lens: bool = false
			
			if Archipelago.is_ap_connected():
				var lens_type_string
				match type:
					Type.FISHEYE:
						lens_type_string = "Fisheye Lens"
					Type.ANTIFISHEYE:
						lens_type_string = "Anti-Fisheye Lens"
					Type.FLIP:
						lens_type_string = "Flip Lens"
					Type.STRETCH:
						lens_type_string = "Stretch Lens"
					Type.COMPRESS:
						lens_type_string = "Compress Lens"
					Type.SWIRL:
						lens_type_string = "Swirl Lens"
					Type.PORTAL_TO:
						lens_type_string = "Portal Lens"
					Type.PORTAL_FROM:
						lens_type_string = "Portal Lens"
					Type.REPLICATOR:
						lens_type_string = "Replicator Lens"
					Type.COLOR:
						lens_type_string = "Color Lens"
				
				var has_xray = false
				var has_apple = false

				for item in Archipelago.conn.received_items:
					if item.get_name() == lens_type_string:
						has_lens = true
					elif item.get_name() == "X-Ray Lens":
						has_xray = true
					elif item.get_name() == "Apple":
						has_apple = true
						
				# XRay only exists when XRay lens and Apple are unlocked 
				if mode_override == 7:
					has_lens = has_xray and has_apple
			
			if has_lens:
				visible = true
			else:
				visible = false
				return

		if is_dragging:]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/levels/feed_level.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[	if spawned > 3 and randf() < 0.2:]]),
		utils.escape(
[[	var apple_unlocked: bool = false
	if Archipelago.is_ap_connected():
		for item in Archipelago.conn.received_items:
			if item.get_name() == "Apple":
				apple_unlocked = true
				break
	if spawned > 3 and randf() < 0.2 and apple_unlocked:]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/levels/feed_level.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[	%BigExplosion.visible = true]]),
		utils.escape(
[[	%BigExplosion.visible = true
	if Archipelago.is_ap_connected() and Archipelago.conn.slot_data["deathlink"] != 0:
		Archipelago.conn.send_deathlink("How Houngry?")]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/levels/fly_level.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func check() -> void :]]),
		utils.escape(
[[func check() -> void :
	var swatter_unlocked: bool = false
	if Archipelago.is_ap_connected():
		for item in Archipelago.conn.received_items:
			if item.get_name() == "Horsefly Swatter":
				swatter_unlocked = true
				break
	
	if !swatter_unlocked:
		return]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/level_editor/level_orchestrator.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[var do_first_level_transition: = true]]),
		utils.escape(
[[var do_first_level_transition: = true
static var level_id_to_location_id: Dictionary = {
	"res://scenes/levels/levels/bulk/level_a01.tscn": 1,
	"res://scenes/levels/levels/bulk/level_a02.tscn": 2,
	"res://scenes/levels/levels/bulk/level_a03.tscn": 3,
	"res://scenes/levels/levels/bulk/level_a04.tscn": 4,
	"res://scenes/levels/levels/bulk/level_a05.tscn": 5,
	"res://scenes/levels/levels/bulk/level_a06.tscn": 6,
	"res://scenes/levels/levels/bulk/level_a07.tscn": 7,
	"res://scenes/levels/levels/bulk/level_a08.tscn": 8,
	"res://scenes/levels/levels/bulk/level_a09.tscn": 9,
	"res://scenes/levels/levels/bulk/level_a10.tscn": 10,
	"res://scenes/levels/levels/bulk/level_a11.tscn": 11,
	"res://scenes/levels/levels/bulk/level_a12.tscn": 12,
	"res://scenes/levels/levels/explode_level.tscn": 13,
	"res://scenes/levels/levels/bulk/level_b01.tscn": 14,
	"res://scenes/levels/levels/bulk/level_b02.tscn": 15,
	"res://scenes/levels/levels/bulk/level_b03.tscn": 16,
	"res://scenes/levels/levels/bulk/level_b04.tscn": 17,
	"res://scenes/levels/levels/bulk/level_b05.tscn": 18,
	"res://scenes/levels/levels/xray_level.tscn": 19,
	"res://scenes/levels/levels/bulk/level_b06.tscn": 20,
	"res://scenes/levels/levels/bulk/level_b07.tscn": 21,
	"res://scenes/levels/levels/bulk/level_b08.tscn": 22,
	"res://scenes/levels/levels/bulk/level_b09.tscn": 23,
	"res://scenes/levels/levels/bulk/level_b10.tscn": 24,
	"res://scenes/levels/levels/bulk/level_c01.tscn": 25,
	"res://scenes/levels/levels/bulk/level_c02.tscn": 26,
	"res://scenes/levels/levels/bulk/level_c06_long2.tscn": 27,
	"res://scenes/levels/levels/bulk/level_c03.tscn": 28,
	"res://scenes/levels/levels/green_horse_level1.tscn": 29,
	"res://scenes/levels/levels/bulk/level_c03.5.tscn": 30,
	"res://scenes/levels/levels/bulk/level_c04.tscn": 31,
	"res://scenes/levels/levels/bulk/level_c05_long1.tscn": 32,
	"res://scenes/levels/levels/green_horse_level2.tscn": 33,
	"res://scenes/levels/levels/bulk/level_c07.tscn": 34,
	"res://scenes/levels/levels/bulk/level_c08.tscn": 35,
	"res://scenes/levels/levels/bulk/level_c09.tscn": 36,
	"res://scenes/levels/levels/green_horse_level3.tscn": 37,
	"res://scenes/levels/levels/feed_level.tscn": 38,
	"res://scenes/levels/levels/bulk/level_d01.tscn": 39,
	"res://scenes/levels/levels/bulk/level_d02.tscn": 40,
	"res://scenes/levels/levels/bulk/level_d05.tscn": 41,
	"res://scenes/levels/levels/bulk/level_d04.tscn": 42,
	"res://scenes/levels/levels/bulk/level_d03.tscn": 43,
	"res://scenes/levels/levels/bulk/level_d06.tscn": 44,
	"res://scenes/levels/levels/bulk/level_d07.tscn": 45,
	"res://scenes/levels/levels/bulk/level_d08.tscn": 46,
	"res://scenes/levels/levels/bulk/level_d09.tscn": 47,
	"res://scenes/levels/levels/fly_level.tscn": 48,
	"res://scenes/levels/levels/bulk/level_d10.tscn": 49,
	"res://scenes/levels/levels/bulk/level_d11.tscn": 50,
	"res://scenes/levels/levels/bulk/level_d12.tscn": 51,
	"res://scenes/levels/levels/bulk/level_d13.tscn": 52,
	"res://scenes/levels/levels/bulk/level_d14.tscn": 53
}]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/level_editor/level_orchestrator.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[	level.won.connect( func() -> void :]]),
		utils.escape(
[=[	level.won.connect( func() -> void :
		print("Level complete: " + game_levels[current_idx - 1])
		if Archipelago.is_ap_connected() and level_id_to_location_id.has(game_levels[current_idx - 1]):
			Archipelago.collect_location(level_id_to_location_id[game_levels[current_idx - 1]])
		else:
			print("Could not collect location.")]=], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/standard_level.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func show_accuracy_meter(score: int) -> void :]]),
		utils.escape(
[[static var standard_level_name_to_perfect_location_id: Dictionary = {
	"level_a01": 101,
	"level_a02": 102,
	"level_a03": 103,
	"level_a04": 104,
	"level_a05": 105,
	"level_a06": 106,
	"level_a07": 107,
	"level_a08": 108,
	"level_a09": 109,
	"level_a10": 110,
	"level_a11": 111,
	"level_a12": 112,
	"level_b01": 113,
	"level_b02": 114,
	"level_b03": 115,
	"level_b04": 116,
	"level_b05": 117,
	"level_b06": 118,
	"level_b07": 119,
	"level_b08": 120,
	"level_b09": 121,
	"level_b10": 122,
	"level_c01": 123,
	"level_c02": 124,
	"level_c06_long2": 125,
	"level_c03": 126,
	"green_horse_level1": 127,
	"level_c03.5": 128,
	"level_c04": 129,
	"level_c05_long1": 130,
	"green_horse_level2": 131,
	"level_c07": 132,
	"level_c08": 133,
	"level_c09": 134,
	"green_horse_level3": 135,
	"level_d01": 136,
	"level_d02": 137,
	"level_d05": 138,
	"level_d04": 139,
	"level_d03": 140,
	"level_d06": 141,
	"level_d07": 142,
	"level_d08": 143,
	"level_d09": 144,
	"level_d10": 145,
	"level_d11": 146,
	"level_d12": 147,
	"level_d13": 148,
	"level_d14": 149,
}

func show_accuracy_meter(score: int) -> void :
	if Archipelago.is_ap_connected() and score <= int(Archipelago.conn.slot_data["leniency"]):
		var level := self as StandardLevel
		var level_name: String = level.level_path
		level_name = level_name.split("/")[level_name.split("/").size() - 1]
		level_name = level_name.split(".tscn")[0]
		print("Level perfected: " + level_name)
		if standard_level_name_to_perfect_location_id.has(level_name):
			print("Sending location: " + str(standard_level_name_to_perfect_location_id[level_name]))
			Archipelago.collect_location(standard_level_name_to_perfect_location_id[level_name])]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/levels/final_boss_level.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func do_intro() -> void :]]),
		utils.escape(
[[func find_node(root: Node, name: String) -> Node:
	if root.name == name:
		return root
	
	for child in root.get_children():
		var node_to_return = find_node(child, name)
		if node_to_return != null:
			return node_to_return
	
	return null

func do_intro() -> void :
	var should_boot = true
	var horse_count = 0
	var horse_total = 40
	var horse_req = 100
	if Archipelago.is_ap_connected():
		horse_total = Archipelago.conn.slot_data["horse_amount"]
		horse_req = Archipelago.conn.slot_data["goal_requirement"]
		for item in Archipelago.conn.received_items:
			if item.get_name() == "Horse":
				horse_count += 1
	
	var true_horse_req: int = int((horse_req / 100.0) * horse_total)
	
	print("Final level loaded with " + str(horse_count) + " horses, out of " + str(true_horse_req) + " required.")
	
	if horse_count < true_horse_req:
		await get_tree().process_frame
		
		var pause_menu: PauseMenu = find_node(self as Node, "PauseMenu") as PauseMenu
		
		print("Is pause menu null: " + str(pause_menu == null))
		
		pause_menu._on_main_menu_pressed()]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/levels/levels/final_boss_level.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func mega_win() -> void :]]),
		utils.escape(
[[func mega_win() -> void :
	if Archipelago.is_ap_connected():
		Archipelago.set_client_status(Archipelago.ClientStatus.CLIENT_GOAL)]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/ui/pause_menu/pause_menu.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func _ready() -> void :]]),
		utils.escape(
[[func deathlink_grenade(source: String, cause: String, json: Dictionary) -> void:
	_on_restart_pressed()

func check_for_grenades(item: NetworkItem) -> void:
	if item.get_name() == "Grenade Trap":
		_on_restart_pressed()

func _ready() -> void :
	if Archipelago.is_ap_connected():
		if int(Archipelago.conn.slot_data["deathlink"]) == 1:
			Archipelago.conn.deathlink.connect(deathlink_grenade)
		
		Archipelago.conn.obtained_item.connect(check_for_grenades)]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/autoloads/jumpscare.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[func launch(zoom: = true) -> void :]]),
		utils.escape(
[[func jumpscare_connect(conn: ConnectionInfo, json: Dictionary) -> void:
	conn.deathlink.connect(deathlink_jumpscare)
	conn.obtained_item.connect(check_for_jumpscare)

func deathlink_jumpscare(source: String, cause: String, json: Dictionary) -> void:
	if int(Archipelago.conn.slot_data["deathlink"]) == 2:
		launch()

func check_for_jumpscare(item: NetworkItem) -> void:
	if item.get_name() == "Jumpscare Trap":
		print("Hit Trap")
		launch()

func _ready() -> void :
	Archipelago.connected.connect(jumpscare_connect)

func launch(zoom: = true) -> void :]], true)
	)
end)

GDPatch.patch_script_as_text("res://scenes/ui/main_menu/level_select.gdc", function(ctx, src)
	return src:gsub(
		utils.escape(
[[		button.set_unlocked(SaveData.unlocked_levels[level])]]),
		utils.escape(
[[		button.set_unlocked(true)]], true)
	)
end)