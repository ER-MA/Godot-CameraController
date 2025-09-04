extends Node2D
class_name Camera2DMove2PositionComponent

@export var controller_component: Camera2DControllerComponent
@export var is_enable: bool = false
@export_group("移动参数")
@export_enum("None", "Lerp", "Smooth") var motion_mode: int = 1 ## 摄像机的运动模式
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖MovenentComponent中的deceleration_speed）
var _mouse_click_position: Vector2
var _target_position_increase: Vector2


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DFollowComponent] 脚本被禁用")
	elif not controller_component:
		push_error("[Camera2DFollowComponent] 未分配或找到 Camera2DControllerComponent")

# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if is_ready():
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				
				# 鼠标右键被松开时
				if not event.pressed:
					controller_component.motion_mode = motion_mode # 覆盖摄像机的运动模式
					controller_component.deceleration_speed = deceleration_speed # 覆盖插值移动速度
					_mouse_click_position = get_global_mouse_position() # 记录鼠标位置
					_target_position_increase = _mouse_click_position - controller_component.get_camera_position()
					controller_component.add_target_position(_target_position_increase)


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()
