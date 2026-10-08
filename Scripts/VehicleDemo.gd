extends Node3D

var Accelerating = false
var Reversing = false

@export var CollisionShapes = []

var IsGrounded = false

@onready var RF_6DOF = $RF_6DOF
@onready var LF_6DOF = $LF_6DOF
@onready var RR_6DOF = $RR_6DOF
@onready var LR_6DOF = $LR_6DOF

@onready var RF_Wheel = $RF_Wheel
@onready var LF_Wheel = $LF_Wheel
@onready var RR_Wheel = $RR_Wheel
@onready var LR_Wheel = $LR_Wheel

# Engine power (multiplies angular motor TARGET VELOCITY): max speed
# Wheel Force Limit (multiplies angular motor FORCE LIMIT): acceleration

@export var ENGINE_POWER = 60 # Top Speed of 150 km/h
@export var WHEEL_FORCE_LIMIT = 10000 # 0-100 km/h in 5.9 seconds (asphalt)
@export var STEER_FORCE = 100

const MAX_STEER_ANGLE = 0.523599 # 30 graus
@export var STEER_SPEED =  3.0

var steer_current = 0

func _ready():
	
	RearSteer(0)
	
	EnableMotor(true)
	
	RF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, WHEEL_FORCE_LIMIT)
	RR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, WHEEL_FORCE_LIMIT)
	LF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, WHEEL_FORCE_LIMIT)
	LR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, WHEEL_FORCE_LIMIT)
	
func _physics_process(delta):

	"""
	
	INPUTS
	
	"""

	Steer(delta)


	if Input.is_action_pressed("Handbrake"):
		#print("brake")
		HandBrake(0)
		
	if Input.is_action_pressed("Reverse"):
		Reverse(Input.get_action_strength("Reverse"))
		
	if Input.is_action_just_pressed(("Reverse")):
		Reversing = true
		
	if Input.is_action_just_released("Reverse"):
		Reverse(0)
		Reversing = false

	if Input.is_action_pressed("Accelerate"):
		Accelerate(Input.get_action_strength("Accelerate"))
		Accelerating = true
		
	if Input.is_action_just_released("Accelerate"):
		Accelerate(0)
		Accelerating = false
		
	if Input.is_action_pressed("RearSteerRight"):
		RearSteer(-Input.get_action_strength("RearSteerRight"))

	if Input.is_action_pressed("RearSteerLeft"):
		RearSteer(Input.get_action_strength("RearSteerLeft"))
			
	if Input.is_action_just_released("RearSteerRight"):
		RearSteer(0)
		
	if Input.is_action_just_released("RearSteerLeft"):
		RearSteer(0)


		
func EnableMotor(enable):
	
	RF_6DOF.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_MOTOR, enable)
	LF_6DOF.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_MOTOR, enable)
	RR_6DOF.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_MOTOR, enable)
	LR_6DOF.set_flag_x(Generic6DOFJoint3D.FLAG_ENABLE_MOTOR, enable)

func Steer(delta):
	var steer_target = MAX_STEER_ANGLE * Input.get_axis("SteerLeft", "SteerRight")
	steer_current = move_toward(steer_current, steer_target, STEER_SPEED * delta)
	for joint in [RF_6DOF, LF_6DOF]:
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, steer_current)
		joint.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, steer_current)
	

func RearSteer(Amount):
	
	#print("RearSteer")
	
	if Amount < 0.1 and Amount > -0.1:
		RR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, 0)
		RR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0)
		
		LR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, 0)
		LR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0)
	else:
		RR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.523599)
		RR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.523599)
		
		LR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_LOWER_LIMIT, -0.523599)
		LR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_UPPER_LIMIT, 0.523599)
		
		RR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * STEER_FORCE)
		LR_6DOF.set_param_y(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * STEER_FORCE)
	
func Accelerate(Amount):
	#print(Amount)
	
	if Amount == 0:
		EnableMotor(false)
		
	else:
		EnableMotor(true)
	
		RF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -Amount * ENGINE_POWER)
		LF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -Amount * ENGINE_POWER)
		RR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -Amount * ENGINE_POWER)
		LR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, -Amount * ENGINE_POWER)
	
func Reverse(Amount):
	if Amount == 0:
		EnableMotor(false)
		
	else:
		EnableMotor(true)
		
		RF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * ENGINE_POWER)
		LF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * ENGINE_POWER)
		RR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * ENGINE_POWER)
		LR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount * ENGINE_POWER)	
	
func HandBrake(Amount):
	EnableMotor(true)
	
	RF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount)
	LF_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount)
	RR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount)
	LR_6DOF.set_param_x(Generic6DOFJoint3D.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, Amount)
