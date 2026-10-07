extends ProgressBar 
var parent 
func _ready(): 
	parent = get_parent() 
	max_value = parent.health_max 
	min_value = parent.health_min 
	value = parent.health 
	visible = false 

func _process(delta): 
	if parent == null: 
		return 
	value = parent.health 
	if parent.health < parent.health_max and parent.health > parent.health_min: 
		visible = true 
	else: 
		visible = false
	
	
	
	
	
	
	
	
