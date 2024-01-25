extends RigidBody3D
##  how much vertical force to apply when moving  
@export_range(750.0,3000.0) var thrust : float =1000.0
@export var torque_thrust : float =100.0
var is_transitioning: bool = false
@onready var fails_audio: AudioStreamPlayer = $FailsAudio
@onready var success_audio: AudioStreamPlayer = $SuccessAudio
@onready var rocket_audio: AudioStreamPlayer3D = $RocketAudio
@onready var booster_particles: GPUParticles3D = $BoosterParticles
@onready var right_booster_particles: GPUParticles3D = $RightBoosterParticles
@onready var left_booster_particles: GPUParticles3D = $LeftBoosterParticles
@onready var explosion_particles: GPUParticles3D = $ExplosionParticles
@onready var success_particles: GPUParticles3D = $SuccessParticles


func _process(delta: float) -> void:
	if Input.is_action_pressed("boost"):
		apply_central_force(basis.y * delta * thrust) 
		booster_particles.emitting=true
		if rocket_audio.playing == false:
			rocket_audio.play()
	else:
		rocket_audio.stop()	
		booster_particles.emitting=false
	
	if Input.is_action_pressed("rotate_left"):
		apply_torque(Vector3(0.0,0.0,torque_thrust * delta))
		right_booster_particles.emitting=true
	else:
		right_booster_particles.emitting=false
		
	
	if Input.is_action_pressed("rotate_right"):
		apply_torque(Vector3(0.0,0.0,-torque_thrust* delta))	
		left_booster_particles.emitting=true
	else:
		left_booster_particles.emitting=false
		
	
		
  

func _on_body_entered(body: Node) -> void:
	if is_transitioning==false:
		if "Goal" in body.get_groups():
			complete_level(body.file_path)
		
		if "hazard" in body.get_groups():
			crash_sequence()

func crash_sequence() -> void:
	print("KABOOM!!!")
	explosion_particles.emitting=true
	fails_audio.play()
	set_process(false)
	is_transitioning=true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().reload_current_scene)

func complete_level(next_level_file: String) -> void:
	print("Level Complete!!!")
	success_particles.emitting=true
	success_audio.play()
	set_process(false)
	is_transitioning=true
	var tween = create_tween()
	tween.tween_interval(2.5)
	tween.tween_callback(get_tree().change_scene_to_file.bind(next_level_file))

