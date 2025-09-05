extends Node2D
class_name Camera2DScrollWheelZoomComponent

@export var controller_component: Camera2DControllerComponent
@export var is_enable: bool = false
@export_group("滚轮缩放参数")
@export var step_size: Vector2 = Vector2(0.1, 0.1) ## 摄像机的缩放步长
@export_subgroup("覆盖参数")
@export_enum("None", "Lerp", "Smooth") var zoom_transition_mode: int = 1 ## 摄像机缩放的过度模式：[br]None: 直接缩放至目标倍率[br]Lerp: 使用 lerp 函数对倍率进行插值[br]Smooth: 使用 move_toward 函数对倍率进行平滑插值
@export_range(1.0, 10.0, 0.1) var zoom_deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:倍率/s") var zoom_smoothing_speed: float = 2.0 ## 摄像机的平滑移动速度
@export_enum("None", "Lerp", "Smooth") var position_transition_mode: int = 1 ## 摄像机的运动过度模式：[br]None: 直接移动至目标位置[br]Lerp: 使用 lerp 函数对坐标进行插值[br]Smooth: 使用 move_toward 函数对坐标进行平滑插值
@export_range(1.0, 10.0, 0.1) var position_deceleration_speed: float = 5.0 ## 摄像机的插值移动速度（会覆盖 MovenentComponent 中的 position_deceleration_speed）
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var position_smoothing_speed: float = 500.0 ## 摄像机的平滑移动速度（会覆盖 MovenentComponent 中的 position_smoothing_speed）
@export_enum("Screen", "Mouse") var zoom_mode: int = 0 ## 摄像机的缩放模式：[br]Screen: 以屏幕为中心进行缩放[br]Mouse: 以鼠标为中心进行缩放
@export var min_zoom: Vector2 = Vector2(0.7, 0.7) ## 摄像机的最小缩放倍率（会覆盖 ControllerComponent 中的 min_zoom）
@export var max_zoom: Vector2 = Vector2(3.0, 3.0) ## 摄像机的最大缩放倍率（会覆盖 ControllerComponent 中的 max_zoom）
var _mouse_world_before: Vector2
var _mouse_world_after: Vector2
var _current_target_zoom: Vector2
var _new_target_zoom: Vector2
var _zoom_ratio: Vector2


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
			if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
				# 上滑滚轮放大
				_cover_zoom_parameter()
				
				if zoom_mode == 0:
					controller_component.add_target_zoom(step_size)
					
				elif zoom_mode == 1:
					_cover_position_parameter()
					# 缩放
					_current_target_zoom = controller_component.target_zoom
					_new_target_zoom = (_current_target_zoom * step_size).clamp(min_zoom, max_zoom)
					controller_component.multiply_target_zoom(_new_target_zoom / _current_target_zoom)
					
					# 基于鼠标位置的缩放中心补偿
					var current_camera_center_mouse_world_position: Vector2 = controller_component.get_viewport_center_mouse_viewport_position() / _current_target_zoom
					var camera_world_position_compensation: Vector2 = current_camera_center_mouse_world_position * ((_new_target_zoom - _current_target_zoom) / _new_target_zoom)
					controller_component.add_target_position(camera_world_position_compensation)
					
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
				# 下滑滚轮缩小
				_cover_zoom_parameter()
				
				if zoom_mode == 0:
					controller_component.add_target_zoom(step_size)
					
				elif zoom_mode == 1:
					_cover_position_parameter()
					# 缩放
					_current_target_zoom = controller_component.target_zoom
					_new_target_zoom = (_current_target_zoom / step_size).clamp(min_zoom, max_zoom)
					controller_component.multiply_target_zoom(_new_target_zoom / _current_target_zoom)
					
					# 基于鼠标位置的缩放中心补偿
					var current_camera_center_mouse_world_position: Vector2 = controller_component.get_viewport_center_mouse_viewport_position() / _current_target_zoom
					var camera_world_position_compensation: Vector2 = current_camera_center_mouse_world_position * ((_new_target_zoom - _current_target_zoom) / _new_target_zoom)
					controller_component.add_target_position(camera_world_position_compensation)


func _cover_zoom_parameter() -> void:
	controller_component.zoom_transition_mode = zoom_transition_mode
	controller_component.zoom_deceleration_speed = zoom_deceleration_speed
	controller_component.zoom_smoothing_speed = zoom_smoothing_speed
	controller_component.min_zoom = min_zoom
	controller_component.max_zoom = max_zoom

func _cover_position_parameter() -> void:
	controller_component.position_transition_mode = position_transition_mode # 覆盖摄像机的运动模式
	controller_component.position_deceleration_speed = position_deceleration_speed # 覆盖插值移动速度
	controller_component.position_smoothing_speed = position_smoothing_speed # 覆盖平滑移动速度


func is_ready() -> bool:
	return is_enable and controller_component and controller_component.is_ready()
