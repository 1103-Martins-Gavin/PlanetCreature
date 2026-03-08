extends Node

var copper = 0
var current_tool = "Hand"
var tool_tier = 0 # 0 = Hand, 1 = Pickaxe, 2 = Laser, etc.
# Defaults to the crash site when you first start the game!
var target_spawn = "CrashSite"
# Keeps track of everything the player destroys
var destroyed_objects = []
