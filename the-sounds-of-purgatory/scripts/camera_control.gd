extends Camera2D


@export var pan: float = 0.25 
@export var smooth_speed: float = 5.0 


func _process(delta: float) -> void:
	# mouse dist
	var mouse_pos = get_local_mouse_position()
	
	# Calculate camera offset towards mouse
	var target_offset = mouse_pos * pan
	
	offset = offset.lerp(target_offset, smooth_speed * delta)
