extends Area2D

const CAMERASHAKETRAUMA:float = 0.32

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		#print("Killzone _on_body_entered: %s"%[body.name])
		SignalHub.emit_on_life_lost()
		SignalHub.emit_on_invoke_camera_shake(CAMERASHAKETRAUMA)
