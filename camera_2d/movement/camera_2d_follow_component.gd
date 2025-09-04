extends Node2D
class_name Camera2DFollowComponent

@export var controller_component: Camera2DControllerComponent
@export var follow_target: Node2D
@export var is_enable: bool = false
@export_group("跟随参数")
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖MovenentComponent中的deceleration_speed）


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DFollowComponent] 脚本被禁用")
	elif not controller_component:
		push_error("[Camera2DFollowComponent] 未分配或找到 Camera2DControllerComponent")

# 物理帧更新
func _physics_process(_delta: float) -> void:
	if is_ready():
		controller_component.target_position = follow_target.position


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()
