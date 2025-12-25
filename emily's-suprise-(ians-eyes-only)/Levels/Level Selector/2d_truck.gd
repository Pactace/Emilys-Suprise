extends TextureRect

@export var squash_speed: float = 1
@export var squash_intensity: float = 1

var size_change = 1
func _process(delta: float) -> void:
	size_change += delta
	scale.x = abs(sin(size_change * squash_speed) * squash_intensity) + 1
	scale.y = abs(cos(size_change * squash_speed) * squash_intensity) + 1
