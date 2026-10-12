extends RefCounted
## Funciones de ayuda compartidas.


## Crea una CollisionShape2D circular y la agrega como hija de `parent`.
static func add_circle_shape(parent: Node, radius: float) -> CollisionShape2D:
	var shape := CircleShape2D.new()
	shape.radius = radius
	var col := CollisionShape2D.new()
	col.shape = shape
	parent.add_child(col)
	return col
