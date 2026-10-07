extends Node
# Apple
var apple = 0;
@onready var ui: CanvasLayer = %UI
var apple_counter;

func _ready():
	apple_counter = ui.get_node("Label")

func add_apple():
	apple += 1
	apple_counter.text = "Apple: " + str(apple)
