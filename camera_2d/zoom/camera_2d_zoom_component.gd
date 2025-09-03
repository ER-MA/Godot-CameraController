extends Node2D
class_name Camera2DZoomComponent

@export var camera: Camera2D
@export var is_enable: bool = false
@export_group("缩放参数")
@export_enum("Lerp", "Smooth") var motion_mode: int = 0 ## 摄像机的缩放模式
@export var target_zoom: Vector2 = Vector2(1.0, 1.0) ## 摄像机目标缩放倍率
#@export_range(0.01, 1.00, 0.01, "suffix:倍率/步") var step_size: float = 0.1 ## 摄像机的缩放步长
#@export_range(0.1, 1.0, 0.1, "suffix:倍率") var min_zoom: float = 0.7 ## 摄像机的最小缩放倍率
#@export_range(1.0, 5.0, 0.1, "suffix:倍率") var max_zoom: float = 3 ## 摄像机的最大缩放倍率
@export var min_zoom: Vector2 = Vector2(0.7, 0.7) ## 摄像机的最小缩放倍率
@export var max_zoom: Vector2 = Vector2(3.0, 3.0) ## 摄像机的最大缩放倍率
@export_range(1.0, 10.0, 0.1) var deceleration_speed: float = 5.0 ## 摄像机的插值移动速度
@export_range(1.0, 1000.0, 1.0, "suffix:倍率/s") var smoothing_speed: float = 2.0 ## 摄像机的平滑移动速度

func _physics_process(delta: float) -> void:
	if is_enable and camera:
		target_zoom = _clamp_zoom(target_zoom)
		if not target_zoom.is_equal_approx(camera.zoom):
			if motion_mode == 0:
				_deceleration_zoom(delta)
			elif motion_mode == 1:
				_smooth_zoom(delta)

func _deceleration_zoom(delta: float) -> void:
	if is_enable and camera:
		camera.zoom = lerp(camera.zoom, target_zoom, delta * deceleration_speed)
	
func _smooth_zoom(delta: float) -> void:
	if is_enable and camera:
		camera.zoom = camera.zoom.move_toward(target_zoom, delta * smoothing_speed)


func _clamp_zoom(zoom: Vector2) -> Vector2:
	return zoom.clamp(min_zoom, max_zoom)
