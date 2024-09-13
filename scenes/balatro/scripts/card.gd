extends Button
### 配置 ###
@export_category("基础配置")
# 最大水平角度(弧度值)
@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
# 阴影最大偏移
@export var max_offset_shadow: float = 50.0

@export_category("振荡配置")
# 弹力
@export var spring: float = 150.0
# 阻尼(减振)
@export var damping: float = 10.0
# 速度系数
@export var velocity_multiplier: float = 2.0

### 变量 ###
# 位移
var displacement: float = 0.0
# 振动速度
var oscillator_velocity: float = 0.0

var last_mouse_pos: Vector2
var mouse_velocity: Vector2
var following_mouse: bool = true
var last_pos: Vector2
var velocity: Vector2

### 动画相关 ###
# 旋转
var tween_rot: Tween
# 鼠标移入
var tween_hover: Tween
# 销毁动画
var tween_destroy: Tween
var tween_handle: Tween

@onready var card_texture: TextureRect = $CardTexture
@onready var shadow: TextureRect = $Shadow
@onready var collision_shape: CollisionShape2D = $DestroyArea/CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 延迟禁用pass
	collision_shape.set_deferred("disabled", true)
	angle_x_max = deg_to_rad(angle_x_max)
	angle_y_max = deg_to_rad(angle_y_max)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	rotate_velocity(_delta)
	follow_mouse(_delta)
	handle_shadow(_delta)

func rotate_velocity(delta: float) -> void:
	if not following_mouse: return
	var center_pos: Vector2 = global_position - (size/2.0)
	# 计算速度
	velocity = (position - last_pos) / delta
	print("Velocity: ", velocity)
	oscillator_velocity += velocity.normalized().x * velocity_multiplier
	
	# Oscillator stuff
	var force = -spring * displacement - damping * oscillator_velocity
	oscillator_velocity += force * delta
	displacement += oscillator_velocity * delta
	
	rotation = displacement
	
func follow_mouse(delta: float) -> void:
	if not following_mouse: return
	var mouse_pos: Vector2 = get_global_mouse_position()
	global_position = mouse_pos - (size/2.0)
	
func handle_shadow(delta: float) -> void:
	# Y position is enver changed.
	# Only x changes depending on how far we are from the center of the screen
	var center: Vector2 = get_viewport_rect().size / 2.0
	var distance: float = global_position.x - center.x
	
	shadow.position.x = lerp(0.0, -sign(distance) * max_offset_shadow, abs(distance/(center.x)))

func handle_mouse_click(event: InputEvent) -> void:
	if not event is InputEventMouseButton: return
	if (event as InputEventMouseButton).button_index != MOUSE_BUTTON_LEFT: return
	if event.is_pressed():
		following_mouse = true
	else:
		following_mouse = false
		collision_shape.set_deferred("disabled", false)
		if tween_handle and tween_handle.is_running():
			tween_handle.kill()
		tween_handle = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		tween_handle.tween_property(self, "rotation", 0.0, 0.3)

func _on_gui_input(event: InputEvent) -> void:
	handle_mouse_click(event)
	if following_mouse: return
	# 如果正在移动就不继续
	if not event is InputEventMouseMotion: return
	var mouse_pos: Vector2 = get_local_mouse_position()
	#print("Mouse: ", mouse_pos)
	#print("Card: ", position + size)
	var diff: Vector2 = (position + size) - mouse_pos

	var lerp_val_x: float = remap(mouse_pos.x, 0.0, size.x, 0, 1)
	var lerp_val_y: float = remap(mouse_pos.y, 0.0, size.y, 0, 1)
	#print("Lerp val x: ", lerp_val_x)
	#print("lerp val y: ", lerp_val_y)

	var rot_x: float = rad_to_deg(lerp_angle(-angle_x_max, angle_x_max, lerp_val_x))
	var rot_y: float = rad_to_deg(lerp_angle(angle_y_max, -angle_y_max, lerp_val_y))
	#print("Rot x: ", rot_x)
	#print("Rot y: ", rot_y)
	
	card_texture.material.set_shader_parameter("x_rot", rot_y)
	card_texture.material.set_shader_parameter("y_rot", rot_x)
