extends Node

# Special thanks to : https://www.reddit.com/user/Cykyrios/ for his Great help

# warning-ignore:unused_argument
func _process(delta):
	$LevelCamera.look_at($Player/Car_Node.global_transform.origin, Vector3.UP)
