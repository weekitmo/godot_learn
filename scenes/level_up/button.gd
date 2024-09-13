extends Button
class_name BButton

@onready var main_texture: TextureRect = %TextureRect
@onready var bottom_label: Label = %Label

func set_label(str: String) -> void:
	bottom_label.text = str

func set_texture(val: ImageTexture) -> void:
	main_texture.texture = val
