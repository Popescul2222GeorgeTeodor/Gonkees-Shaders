extends TouchScreenButton

# Gonkee's joystick script for Godot 3 - full tutorial https://youtu.be/uGyEP2LUFPg
# If you use this script, I would prefer if you gave credit to me and gonkee

# Change these based on the size of your button and outer sprite
#Joystick's handle radius,keep same value on both coordinates
export(Vector2) var radius = Vector2(32,32)
#max distance for the handle to move 
export(int) var boundary = 64
#keeps track of current drag,-1 means nothing's touching the screen
var ongoing_drag = -1
#at what speed the handle will return to center
export(int) var return_accel = 20
#enable this to see if the joystick is working
#WARNING,your console will get spammed with info
export(bool) var debugging = false;
#how much we have to move joystick to register movement
#values lower than this will be ignored
export(int) var threshold = 10
#if enabled,the length of the movement vector will not be constant
#basically an analog controller
export(bool) var analog = false 
func _process(delta):
	if debugging:
		print(get_value())
	if ongoing_drag == -1:
		var pos_difference = (Vector2(0, 0) - radius) - position
		position += pos_difference * return_accel * delta

func get_button_pos():
	return position + radius

func _input(event):
	if event is InputEventScreenDrag or (event is InputEventScreenTouch and event.is_pressed()):
		var event_dist_from_centre = (event.position - get_parent().global_position).length()

		if event_dist_from_centre <= boundary * global_scale.x or event.get_index() == ongoing_drag:
			set_global_position(event.position - radius * global_scale)

			if get_button_pos().length() > boundary:
				set_position( get_button_pos().normalized() * boundary - radius)

			ongoing_drag = event.get_index()

	if event is InputEventScreenTouch and !event.is_pressed() and event.get_index() == ongoing_drag:
		ongoing_drag = -1

#this is what you use to move the character
func get_value():
	if get_button_pos().length() > threshold:
		if analog:
			return get_button_pos()
		else:
			return get_button_pos().normalized()
	return Vector2(0, 0)

#use this for aiming using the joystick
#make sure to use rotation not rotation_degrees
func get_aim():
	var dir= get_value();
	return atan2(dir.y,dir.x);
