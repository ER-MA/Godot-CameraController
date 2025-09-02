extends Node2D
class_name Camera2DMovementComponent

@export var camera_2d: Camera2D
@export_group("运动参数")
@export_enum("Lerp", "Smooth") var motion_mode: int = 0 ## 摄像机的运动模式
@export var target_position: Vector2 = Vector2(0, 0) ## 摄像机目标位置
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var smoothing_speed: float = 200.0 ## 摄像机的平滑移动速度


func _physics_process(delta: float) -> void:
	if camera_2d:
		
		if not target_position.is_equal_approx(camera_2d.position):
			if motion_mode == 0:
				_deceleration_movement(delta)
			elif motion_mode == 1:
				_smooth_movement(delta)

func _deceleration_movement(delta: float) -> void:
	if camera_2d:
		camera_2d.position = lerp(camera_2d.position, target_position, delta * deceleration_speed)
	
func _smooth_movement(delta: float) -> void:
	if camera_2d:
		camera_2d.position = camera_2d.position.move_toward(target_position, delta * smoothing_speed)


# TODO:
# 配置文件分离，创建独立的配置资源
# 封装参数，阻止外部直接修改
