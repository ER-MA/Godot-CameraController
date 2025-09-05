extends Node2D
class_name Camera2DControllerComponent
## 用于控制2D摄像机的基础组件。其他与摄像机位置、缩放等功能相关的组件均以该组件为前置。

@export var camera: Camera2D ## 本脚本将作用于选中的摄像机（子组件调用时请使用get_camera()以确保获得有效的示例）
@export var is_enable: bool = false
# 运动变量
@export_group("运动参数")
@export_enum("None", "Lerp", "Smooth") var position_transition_mode: int = 0 ## 摄像机的运动过度模式：[br]None: 直接移动至目标位置[br]Lerp: 使用 lerp 函数对坐标进行插值[br]Smooth: 使用 move_toward 函数对坐标进行平滑插值
@export_range(1.0, 10.0, 0.1) var position_deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var position_smoothing_speed: float = 200.0 ## 摄像机的平滑移动速度
@export var target_position: Vector2 = Vector2(0, 0) ## 摄像机目标位置
# 缩放变量
@export_group("缩放参数")
@export_enum("None", "Lerp", "Smooth") var zoom_transition_mode: int = 0 ## 摄像机的缩放过度模式：[br]None: 直接缩放至目标倍率[br]Lerp: 使用 lerp 函数对倍率进行插值[br]Smooth: 使用 move_toward 函数对倍率进行平滑插值
@export_range(1.0, 10.0, 0.1) var zoom_deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:倍率/s") var zoom_smoothing_speed: float = 2.0 ## 摄像机的平滑移动速度
@export var target_zoom: Vector2 = Vector2(1.0, 1.0) ## 摄像机目标缩放倍率
@export var min_zoom: Vector2 = Vector2(0.7, 0.7) ## 摄像机的最小缩放倍率
@export var max_zoom: Vector2 = Vector2(3.0, 3.0) ## 摄像机的最大缩放倍率


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DControllerComponent] 脚本被禁用")
	elif not camera:
		push_error("[Camera2DControllerComponent] 未分配或找到 Camera2D")

func _physics_process(delta: float) -> void:
	#prints(get_camera_center_mouse_world_position(), get_viewport_center_mouse_viewport_position())
	if is_ready():
		# 运动相关
		if not target_position.is_equal_approx(camera.position):
			if position_transition_mode == 0:
				_none_movement()
			elif position_transition_mode == 1:
				_deceleration_movement(delta)
			elif position_transition_mode == 2:
				_smooth_movement(delta)
			else:
				_none_movement()
		# 缩放相关
		target_zoom = _clamp_zoom(target_zoom)
		if not target_zoom.is_equal_approx(camera.zoom):
			if zoom_transition_mode == 0:
				_none_zoom()
			elif zoom_transition_mode == 1:
				_deceleration_zoom(delta)
			elif zoom_transition_mode == 2:
				_smooth_zoom(delta)


# 运动私有函数
func _none_movement() -> void:
	camera.position = target_position
	
func _deceleration_movement(delta: float) -> void:
	camera.position = lerp(camera.position, target_position, delta * position_deceleration_speed)
	
func _smooth_movement(delta: float) -> void:
	camera.position = camera.position.move_toward(target_position, delta * position_smoothing_speed)

# 缩放私有函数
func _none_zoom() -> void:
	camera.zoom = target_zoom
	
func _deceleration_zoom(delta: float) -> void:
	camera.zoom = lerp(camera.zoom, target_zoom, delta * zoom_deceleration_speed)
	
func _smooth_zoom(delta: float) -> void:
	camera.zoom = camera.zoom.move_toward(target_zoom, delta * zoom_smoothing_speed)
	
func _clamp_zoom(zoom: Vector2) -> Vector2:
	return zoom.clamp(min_zoom, max_zoom)


# 公有函数
func add_target_position(increase: Vector2) -> void:
	target_position += increase
	
func add_target_zoom(increase: Vector2) -> void:
	target_zoom += increase
	
func multiply_target_zoom(multiplier: Vector2) -> void:
	target_zoom = target_zoom * multiplier
	
func get_camera_position() -> Vector2:
	return camera.position
	
func get_camera_zoom() -> Vector2:
	return camera.zoom

func get_camera_local_mouse_position() -> Vector2:
	return camera.get_local_mouse_position() # 鼠标相对于摄像机的世界坐标
	
func get_viewport_center_mouse_viewport_position() -> Vector2: # 获取相对于视口中心的鼠标视口坐标（不受摄像机缩放影响，受窗口拉伸的影响）
	return get_viewport().get_mouse_position() - Vector2(get_viewport().size) / 2.0
	
func get_camera_center_mouse_world_position() -> Vector2: # 获取相对于摄像机中心的鼠标世界坐标（受缩放影响）
	return get_viewport_center_mouse_viewport_position() / camera.zoom
	
func get_world_center_camera_world_position() -> Vector2: # 获取相对于世界中心的摄像机中心点的世界坐标（与缩放无关）
	return camera.get_screen_center_position()
	
func get_world_center_mouse_world_position() -> Vector2: # 获取相对于世界中心的鼠标世界坐标
	return get_world_center_camera_world_position() + get_camera_center_mouse_world_position()
	
func get_world_center_mouse_position() -> Vector2: # 获取相对于世界中心的鼠标坐标（也就是鼠标指的向物体的世界坐标）
	# 返回鼠标在游戏世界坐标系中的绝对坐标
	var viewport_size := Vector2(get_viewport().size) # 将Viewport尺寸转换为Vector2类型
	var screen_center := viewport_size / 2.0 # 计算屏幕中心点
	var mouse_screen_pos := get_viewport().get_mouse_position() # 获取鼠标位置
	var screen_offset := mouse_screen_pos - screen_center # 计算偏移量
	return camera.get_screen_center_position() + screen_offset / camera.zoom # 应用缩放转换
	

func is_ready() -> bool:
	return is_enable and camera


# TODO:
# 配置文件分离，创建独立的配置资源
# 封装参数，阻止外部直接修改
