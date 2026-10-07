@tool
class_name Boulder
extends RigidBody3D

@export var radius: float = 1.0:
	set(value):
		radius = value
		_update_size()
		
@onready var mesh_node: MeshInstance3D = $MeshInstance3D
@onready var shape_node: CollisionShape3D = $CollisionShape3D

func _update_size():
	if not is_inside_tree():
		return

	if mesh_node and mesh_node.mesh is SphereMesh:
		mesh_node.mesh.radius = radius
		mesh_node.mesh.height = radius * 2.0

	if shape_node and shape_node.shape is SphereShape3D:
		shape_node.shape.radius = radius
