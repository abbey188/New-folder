extends GPUParticles2D

func _ready():
	# Set up particle properties
	process_material = ParticleProcessMaterial.new()
	process_material.emission_shape = BaseMaterial3D.EMISSION_SHAPE_POINT
	process_material.particle_flag_disable_z = true
	process_material.gravity = Vector3(0, 0, 0)
	process_material.initial_velocity_min = 50
	process_material.initial_velocity_max = 100
	process_material.scale_min = 2
	process_material.scale_max = 4
	process_material.color = Color(1, 1, 1, 1)
	
	# Connect finished signal
	finished.connect(_on_finished)

func _on_finished():
	queue_free() 