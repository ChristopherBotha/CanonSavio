extends Resource

func _reparent(child: Node, new_parent: Node)-> void:
	var old_parent = child.get_parent()
	old_parent.remove_child(child)
	new_parent.add_child(child)
