extends Node2D
class_name Camera2DMovementComponent

@export var camera: Camera2D ## 本脚本将作用于选中的摄像机（子组件调用时请使用get_camera()以确保获得有效的示例）
@export var is_enable: bool = false
@export_group("运动参数")
@export_enum("None", "Lerp", "Smooth") var motion_mode: int = 0 ## 摄像机的运动模式
@export var target_position: Vector2 = Vector2(0, 0) ## 摄像机目标位置
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var smoothing_speed: float = 200.0 ## 摄像机的平滑移动速度


func _ready() -> void:
	# 组件自检
	if not is_enable:
		push_warning("[Camera2DMovementComponent] 脚本被禁用")
	elif not camera:
		push_error("[Camera2DMovementComponent] 未分配或找到 Camera2D")

func _physics_process(delta: float) -> void:
	if is_ready():
		
		if not target_position.is_equal_approx(camera.position):
			if motion_mode == 0:
				_none_movement()
			elif motion_mode == 1:
				_deceleration_movement(delta)
			elif motion_mode == 2:
				_smooth_movement(delta)
			else:
				_none_movement()


func _none_movement() -> void:
	camera.position = target_position
	
func _deceleration_movement(delta: float) -> void:
	camera.position = lerp(camera.position, target_position, delta * deceleration_speed)
	
func _smooth_movement(delta: float) -> void:
	camera.position = camera.position.move_toward(target_position, delta * smoothing_speed)


func add_target_position(increase: Vector2) -> void:
	target_position += increase
	
func get_camera_position() -> Vector2:
	return camera.position
	

func is_ready() -> bool:
	return is_enable and camera


# TODO:
# 配置文件分离，创建独立的配置资源
# 封装参数，阻止外部直接修改
