extends Node2D
class_name Camera2DScrollWheelZoomComponent

@export var controller_component: Camera2DControllerComponent
@export var is_enable: bool = false
@export_group("滚轮缩放参数")
@export var step_size: Vector2 = Vector2(0.1, 0.1) ## 摄像机的缩放步长
@export_subgroup("覆盖参数")
@export_enum("None", "Lerp", "Smooth") var transition_mode: int = 1 ## 摄像机的缩放模式：[br]None: 直接缩放至目标倍率[br]Lerp: 使用 lerp 函数对倍率进行插值[br]Smooth: 使用 move_toward 函数对倍率进行平滑插值
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:倍率/s") var smoothing_speed: float = 2.0 ## 摄像机的平滑移动速度


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DScrollWheelZoomComponent] 脚本被禁用")
	elif not controller_component:
		push_error("[Camera2DScrollWheelZoomComponent] 未分配或找到 Camera2DZoomComponent")

# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if is_ready():
		
		if event is InputEventMouseButton:
			# 滚轮缩放
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# 上滑滚轮放大
				_cover_parameter()
				controller_component.target_zoom += step_size
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# 下滑滚轮缩小
				_cover_parameter()
				controller_component.target_zoom -= step_size

func _cover_parameter() -> void:
	controller_component.zoom_transition_mode = transition_mode
	controller_component.zoom_deceleration_speed = deceleration_speed
	controller_component.zoom_smoothing_speed = smoothing_speed


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()
