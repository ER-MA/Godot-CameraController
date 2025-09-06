extends Control
class_name InputMapper

const  KEYMAPS_PATH = "user://keymaps.dat" # 按键映射文件的保存路径（需要在高级设置的“应用->配置”中开启和设置用户自定义目录）
var keymaps: Dictionary


func _ready() -> void:
	for action in InputMap.get_actions(): # 获取当前项目中所有的动作
		if InputMap.action_get_events(action).size() != 0: # 若动作中存在事件
			keymaps[action] = InputMap.action_get_events(action)[0] # 则将动作添加为键，事件赋为值
	# 加载本地缓存的按键映射
	load_keymaps()
	# 加载完成后让所有子节点更新文本（危险！！！）
	for button in get_children():
		button.update_text()


func load_keymaps() -> void:
	if FileAccess.file_exists(KEYMAPS_PATH): # 若文件存在于路径中
		var file: FileAccess = FileAccess.open(KEYMAPS_PATH, FileAccess.READ)
		var local_keymaps: Dictionary = file.get_var(true) as Dictionary
		file.close()
		# 替换为加载的本地按键映射
		for action in keymaps.keys():
			if local_keymaps.has(action):
				InputMap.action_erase_events(action)
				InputMap.action_add_event(action, local_keymaps[action])
				keymaps[action] = InputMap.action_get_events(action)[0]
				# 另一种写法，但是感觉没上面这种靠谱
				#keymaps[action] = local_keymaps[action]
				#InputMap.action_erase_events(action)
				#InputMap.action_add_event(action, keymaps[action])
		
	else: # 若文件不存在
		save_keymaps()

func save_keymaps() -> void:
	var file: FileAccess = FileAccess.open(KEYMAPS_PATH, FileAccess.WRITE)
	file.store_var(keymaps, true)
	file.close()
