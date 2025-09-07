extends Control
class_name InputMapper

signal action_changed(action: String) # 持有该节点的按钮通过这个信号告诉所有人哪个动作被更新了

@export var is_enable: bool = true
@export var keymaps_path: String = "user://keymaps.dat" ## 按键映射文件的保存路径（需要在高级设置的“应用->配置”中开启和设置用户自定义目录）
var keymaps: Dictionary # 缓存当前项目中所有动作和事件数组的键值对（动作数量取决于该脚本实例化时编辑器中的动作数量）


func _ready() -> void:
	if is_ready():
		load_keymaps() # 加载本地缓存的按键映射（子节点会自己在ready阶段更新文本）
		# 持有本节点的 remapper 脚本会在 ready 信号发出后更新所有文本
		# 持有本节点的 remapper 脚本会在 action_changed 信号发出后更新对应 action 的文本
		action_changed.connect(_on_action_changed) # 由本脚本将更新后的按键映射保存至本地


func _on_action_changed(_action: String) -> void:
	if is_enable:
		save_keymaps() # remapper 脚本更新后通知本脚本覆盖保存按键映射


func _update_keymaps() -> void:
	if is_enable:
		for action in InputMap.get_actions(): # 获取当前项目中所有的动作
			keymaps[action] = InputMap.action_get_events(action) # 则将动作添加为键，事件赋为值
			# （不管返回的事件数组是否为空，先把动作存上，以防止编辑器中的动作未配置事件导致本地事件无法被加载）


func load_keymaps() -> void:
	if is_enable and keymaps_path:
		# 缓存编辑器中的所有动作到 keymaps
		_update_keymaps()
		
		# 若文件存在于路径中
		if FileAccess.file_exists(keymaps_path):
			# 开启并读取数据
			var file: FileAccess = FileAccess.open(keymaps_path, FileAccess.READ)
			var local_keymaps: Dictionary = file.get_var(true) as Dictionary
			file.close()
			
			# 替换按键映射
			for action in keymaps.keys():
				if local_keymaps.has(action):
					InputMap.action_erase_events(action)
					for event in local_keymaps[action]:
						InputMap.action_add_event(action, event)
					keymaps[action] = InputMap.action_get_events(action)
					
		# 若文件不存在
		else:
			# 保存按键映射到本地
			save_keymaps() 
			

func save_keymaps() -> void:
	if is_enable and keymaps_path:
		# 先从编辑器更新按键映射缓存 keymaps
		_update_keymaps()
		# 再写入文件
		var file: FileAccess = FileAccess.open(keymaps_path, FileAccess.WRITE)
		file.store_var(keymaps, true)
		file.close()
		print("save_keymaps")


func is_ready() -> bool:
	# 组件自检
	if not is_enable:
		push_warning("[%s] 此脚本被禁用" % self.get_script().get_global_name())
		return false
		
	if not keymaps_path:
		push_error("[%s] 未配置按键映射文件的保存路径" % self.get_script().get_global_name())
		return false
		
	return true
