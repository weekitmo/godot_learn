extends Control
@onready var wing_l_particles: GPUParticles2D = $WingLParticles
@onready var wing_r_particles: GPUParticles2D = $WingRParticles
@onready var button_container: HBoxContainer = $ButtonContainer
@onready var level: Label = $Anchor/Shield/Level
@onready var level_number: Label = $Anchor/Shield/LevelNumber
@onready var title: Label = $Title
@onready var wing_r = $Anchor/Shield/WingR
@onready var wing_l = $Anchor/Shield/WingL
@onready var ribbon = $Ribbon
@onready var rewards = $Ribbon/Rewards
@onready var shield = $Anchor/Shield

var tween: Tween
var tween2: Tween
var tween_buttons: Tween
var current_level = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	wing_l_particles.emitting = false
	wing_r_particles.emitting = false
	
	wing_r.scale = Vector2.ZERO
	wing_l.scale = Vector2.ZERO
	
	shield.scale = Vector2.ZERO
	
	title.self_modulate.a = 0.0
	level.self_modulate.a = 0.0
	level_number.self_modulate.a = 0.0
	level_number.text = "0"
	
	ribbon.scale.x = 0.0
	rewards.self_modulate.a = 0.0
	
	animate()
	for child in button_container.get_children():
		child.modulate.a = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func animate() -> void:
	tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween2 = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_interval(0.4)
	tween.tween_property(title, "self_modulate:a", 1.0, 0.8)
	print(shield)
	tween.parallel().tween_property(shield, "scale", Vector2.ONE, 1.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(shield.material, "shader_parameter/y_rot", 180.0, 1.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# 等级
	tween.parallel().tween_property(level, "self_modulate:a", 1.0, 1)
	tween.parallel().tween_property(level_number, "self_modulate:a", 1.0, 1)
	tween.tween_method(count_up.bind(level_number), 0, current_level, 1.2)
	
	# Wings
	tween2.tween_interval(1.2)
	tween2.tween_property(wing_r, "position:x", wing_r.position.x, 0.15).from(wing_r.position.x - 150)
	tween2.parallel().tween_property(wing_l, "position:x", wing_l.position.x, 0.15).from(wing_l.position.x + 150)
	tween2.parallel().tween_property(wing_r, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween2.parallel().tween_property(wing_l, "scale", Vector2.ONE, 0.9).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween2.tween_callback(wing_l_particles.restart)
	tween2.tween_callback(wing_r_particles.restart)
	
	# Ribbon
	tween.tween_property(ribbon, "scale:x", 1.0, 0.65).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(rewards, "self_modulate:a", 0.75, 1)
	
	# 底部按钮
	for child in button_container.get_children():
		# 调整button CanvasItem下的 Visibility 下 Modulate颜色的透明度，终值，持续时间
		tween.tween_property(child, "modulate:a", 1.0, 0.15)
		# 让下一个 Tweener 与上一个并行执行。
		tween.parallel().tween_property(child, "position:y", position.y, 0.7).from(position.y+200)
		# 创建一个0.05s的延迟，再继续执行下一个
		tween.tween_interval(0.05)
		
	tween.tween_callback(start_buttons_loop)

func start_buttons_loop() -> void:
	tween_buttons = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween_buttons.set_loops()
	for child in button_container.get_children():
		tween_buttons.tween_property(child, "scale", Vector2(1.1, 1.1), 0.2)
		tween_buttons.tween_property(child, "scale", Vector2.ONE, 0.2)
	tween_buttons.tween_interval(1)


func count_up(value: int, label: Label) -> void:
	label.text = str(value)
