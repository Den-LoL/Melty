extends Node

const MOD_ID := "Melty-MinecraftErdet"

var blocks_data := {}
var items_data := {}
var recipes_data := {}
var player_inventory := {}
var hotbar_slots := 9
var selected_hotbar_slot := 0
var block_meshes := {}
var item_meshes := {}

func _init() -> void:
	var path := ModLoaderMod.get_unpacked_dir().path_join(MOD_ID).path_join("extensions/minecraft_system.gd")
	ModLoaderMod.install_script_extension(path)
	print("[MinecraftErdet] Mod initialized")
