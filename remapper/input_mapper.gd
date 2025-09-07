extends Control
class_name InputMapper

const  KEYMAPS_PATH = "user://keymaps.dat" # 按键映射文件的保存路径（需要在高级设置的“应用->配置”中开启和设置用户自定义目录）
var keymaps: Dictionary # 当前项目中所有动作和事件数组的键值对（动作数量取决于该脚本实例化时编辑器中的动作数量）


func _init() -> void:
	# 缓存编辑器中的所有动作
	_update_keymaps()
	# 加载本地缓存的按键映射（子节点会自己在ready阶段更新文本）
	load_keymaps()

func _ready() -> void:
	pass


func _update_keymaps() -> void:
	for action in InputMap.get_actions(): # 获取当前项目中所有的动作
		keymaps[action] = InputMap.action_get_events(action) # 则将动作添加为键，事件赋为值
		# （不管返回的事件数组是否为空，先把动作存上，以防止编辑器中的动作未配置事件导致本地事件无法被加载）


func load_keymaps() -> void:
	if FileAccess.file_exists(KEYMAPS_PATH): # 若文件存在于路径中
		# 开启并读取数据
		var file: FileAccess = FileAccess.open(KEYMAPS_PATH, FileAccess.READ)
		var local_keymaps: Dictionary = file.get_var(true) as Dictionary
		file.close()
		
		# 替换按键映射
		for action in keymaps.keys():
			if local_keymaps.has(action):
				InputMap.action_erase_events(action)
				for event in local_keymaps[action]:
					InputMap.action_add_event(action, event)
				keymaps[action] = InputMap.action_get_events(action)
			
	else: # 若文件不存在
		save_keymaps() # 保存按键映射缓存到本地

func save_keymaps() -> void:
	_update_keymaps() # 先从编辑器更新，再缓存
	var file: FileAccess = FileAccess.open(KEYMAPS_PATH, FileAccess.WRITE)
	file.store_var(keymaps, true)
	file.close()
