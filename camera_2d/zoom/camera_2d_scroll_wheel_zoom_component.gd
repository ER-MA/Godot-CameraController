extends Node2D
class_name Camera2DScrollWheelZoomComponent

@export var zoom_component: Camera2DZoomComponent
@export var is_enable: bool = false
@export_category("滚轮缩放参数")
@export_enum("Lerp", "Smooth") var motion_mode: int = 0 ## 摄像机的缩放模式
@export var step_size: Vector2 = Vector2(0.1, 0.1) ## 摄像机的缩放步长
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:倍率/s") var smoothing_speed: float = 2.0 ## 摄像机的平滑移动速度
#var _is_zoom_process: bool = false
#var _target_zoom: Vector2 = Vector2(1.0, 1.0) ## 摄像机目标缩放倍率


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DScrollWheelZoomComponent] 脚本被禁用")
	elif not zoom_component:
		push_error("[Camera2DScrollWheelZoomComponent] 未分配或找到 Camera2DZoomComponent")

# 输入处理
func _unhandled_input(event: InputEvent) -> void:
	if is_ready():
		
		if event is InputEventMouseButton:
			# 滚轮缩放
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				# 上滑滚轮放大
				zoom_component.motion_mode = motion_mode
				zoom_component.deceleration_speed = deceleration_speed
				zoom_component.smoothing_speed = smoothing_speed
				zoom_component.target_zoom += step_size
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				# 下滑滚轮缩小
				zoom_component.motion_mode = motion_mode
				zoom_component.deceleration_speed = deceleration_speed
				zoom_component.smoothing_speed = smoothing_speed
				zoom_component.target_zoom -= step_size


func is_ready() -> bool:
	return is_enable and zoom_component and zoom_component.is_ready()
