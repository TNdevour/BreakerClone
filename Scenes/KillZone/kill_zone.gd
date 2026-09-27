extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Ball:
		print("Killzone _on_body_entered: %s"%[body.name])
		SignalHub.emit_on_life_lost()
