extends Node

func new_tween(_tween: Tween, node: Node, e:= Tween.EASE_OUT, t:= Tween.TransitionType.TRANS_EXPO) -> Tween:
	if _tween: _tween.kill()

	var tween = node.create_tween()

	tween.set_ease(e)
	tween.set_trans(t)

	return tween
