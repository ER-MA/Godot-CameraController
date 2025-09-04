extends Node2D
class_name Camera2DMove2PositionComponent

@export var controller_component: Camera2DControllerComponent
@export var is_enable: bool = false
@export_group("移动参数")
@export_enum("None", "Lerp", "Smooth") var transition_mode: int = 1 ## 摄像机的运动过度模式：[br]None: 直接移动至目标位置[br]Lerp: 使用 lerp 函数对坐标进行插值[br]Smooth: 使用 move_toward 函数对坐标进行平滑插值
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖 MovenentComponent 中的 position_deceleration_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var smoothing_speed: float = 500.0 ## 摄像机的平滑移动速度（会覆盖 MovenentComponent 中的 position_smoothing_speed）
var _mouse_click_position: Vector2
var _target_position_increase: Vector2


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DMove2PositionComponent] 脚本被禁用")
	elif not controller_component:
		push_error("[Camera2DMove2PositionComponent] 未分配或找到 Camera2DControllerComponent")

# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if is_ready():
		
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				
				# 鼠标被松开时
				if not event.pressed:
					_cover_parameter()
					_mouse_click_position = get_global_mouse_position() # 记录鼠标位置
					_target_position_increase = _mouse_click_position - controller_component.get_camera_position() # 计算相对位置，以使用 add 函数调整摄像机目标位置
					controller_component.add_target_position(_target_position_increase)


func _cover_parameter() -> void:
	controller_component.position_transition_mode = transition_mode # 覆盖摄像机的运动模式
	controller_component.position_deceleration_speed = deceleration_speed # 覆盖插值移动速度
	controller_component.position_smoothing_speed = smoothing_speed # 覆盖平滑移动速度


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()
