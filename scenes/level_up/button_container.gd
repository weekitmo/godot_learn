extends HBoxContainer

var my_button := preload("res://scenes/level_up/button.tscn")

var button_map = [
	{
		"name": "Bomb",
		"image_path": "res://scenes/level_up/assets/bomb.png"
	},
	{
		"name": "Clover",
		"image_path": "res://scenes/level_up/assets/clover.png"
	},
	{
		"name": "Heart",
		"image_path": "res://scenes/level_up/assets/heart.png"
	},
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for item in button_map:
		var instance:BButton = my_button.instantiate()
		add_child(instance)
		instance.set_label(item["name"])
		var image_texture = load_texture(item["image_path"])
		instance.set_texture(image_texture)

func load_texture(img_path: String) -> ImageTexture:
	var texture = ImageTexture.new()
	var img = Image.load_from_file(img_path)
	texture = texture.create_from_image(img)
	return texture
